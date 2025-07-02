import requests
from io import BytesIO
import urllib3
import numpy as np
import pandas as pd
import re
import os
import spacy
from pathlib import Path
import torch
import platform
from sentence_transformers import SentenceTransformer
from tqdm import tqdm

class FishBaseAPI:
    def __init__(self):
        self.base_url = "https://fishbase.ropensci.org/fishbase"
        self.datasets_dir = Path('./datasets')
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


    def get_raw_data(self):
        try:
            print("1. Downloading FishBase dataset...")
            species_url = f"{self.base_url}/species.parquet"

            # Загружаем parquet-файл
            response = requests.get(species_url, verify=False, timeout=30)
            response.raise_for_status()

            # Читаем данные в DataFrame
            species_df = pd.read_parquet(BytesIO(response.content))
            print(f"Successfully downloaded {len(species_df)} records of fish species!")

            # Сохраняем в CSV
            self.datasets_dir.mkdir(exist_ok=True, parents=True)

            output_file = self.datasets_dir / "raw_fishbase.csv"
            species_df.to_csv(output_file, index=False)
            print(f"Downloaded data saved in: {output_file}")

            return pd.read_csv(output_file)

        except Exception as e:
            print(f"Error: {e}")
            return None

class DataProcessor:
    def __init__(self):
        self.fishbase_api = FishBaseAPI()
        # self.translator = pipeline(
        #     'translation_en_to_ru',
        #     model = "Helsinki-NLP/opus-mt-en-ru"
        # )
        # self.translator = pipeline(
        #     "translation",
        #     model="facebook/nllb-200-distilled-600M",
        #     src_lang="eng_Latin",
        #     tgt_lang="rus_Cyrl"
        # )
        self.embedder = SentenceTransformer(
            "Qwen/Qwen3-Embedding-0.6B",
            model_kwargs={"attn_implementation":"eager", "device_map": "auto"},
            tokenizer_kwargs={"padding_side": "left"}
        )

    def process_raw_data(self, translation: bool = False, addition_to_db: bool = False):
        raw_data = self.fishbase_api.get_raw_data()
        print("Loading raw data...")
        # raw_data = pd.read_csv('./datasets/preprocessed_fishbase.csv')
        print(f"Loaded {len(raw_data)} records from raw data")

        #retrieved useful columns
        data = raw_data[['Genus', 'Species', 'FBname',
                         'BodyShapeI', 'Length', 'Weight', 'AirBreathing', 'LongevityWild', 'Dangerous',
                         'Fresh', 'Brack', 'Saltwater', 'DepthRangeShallow', 'DepthRangeDeep',
                         'MainCatchingMethod', 'Comments']]

        #привел данные к нижнему регистру там где были отличия у данных в только регистре
        data['FBname'] = data['FBname'].str.lower()
        data['BodyShapeI'] = data['BodyShapeI'].str.lower()
        data['Dangerous'] = data['Dangerous'].str.lower()

        #removed excessive types from AirBreathing column
        fix_air_breathing = {'WaterAssumed': 'Water',
                             'Water':'Water',
                             'FacultativeGenus':'Air&Water',
                             'Facultative':'Air&Water',
                             'FacultativeObligate':'Air&Water',
                             'Obligate': 'Air',
                             'ObligateGenus':'Air',
                             np.nan: 'unknown'}
        data['AirBreathing'] = data['AirBreathing'].apply(lambda x: fix_air_breathing.get(x, 'unknown'))

        #added new column to save the description for embeddings
        print("2. Creating full descriptions...")
        tqdm.pandas(desc="Creating descriptions")
        data['FullDescription_en'] = data.progress_apply(
            lambda row: f"{row['Species']} aka {row['FBname']} (Genus-{row['Genus']}): has {row['BodyShapeI']} bodyshape, common length {row['Length']} and weight {row['Weight']}, live up to {row['LongevityWild']} years; Assumed {row['AirBreathing']} breathing, {row['Dangerous']} for human. Lives in {int(row['Fresh']) * 'fresh ' if pd.notna(row['Fresh']) else ''}{int(row['Brack']) * 'brack ' if pd.notna(row['Brack']) else ''}{int(row['Saltwater'])*'salt ' if pd.notna(row['Saltwater']) else ''}water common depth {row['DepthRangeShallow']}-{row['DepthRangeDeep']} metres. Main catching method is {row['MainCatchingMethod']}.",
            axis=1
        )
        
        print("3. Cleaning text descriptions...")
        tqdm.pandas(desc="Cleaning text")
        data['cleaned_discription'] = data['FullDescription_en'].progress_apply(
            lambda row: self.clean_text(row)
        )

        print("4. Generating embeddings...")
        embeddings_en = self.embedder.encode(
            data['cleaned_discription'],
            convert_to_numpy=True,
            show_progress_bar=True,
            batch_size=32
        )
        
        embeddings_en_df = pd.DataFrame(embeddings_en)
        
        full_data = data.combine_first(embeddings_en_df)

        if translation:
            self.add_translation(data)
        
        full_data.to_csv(self.fishbase_api.datasets_dir / "preprocessed_fishbase.csv")
        print(f"Preprocessed dataset saved to: {self.fishbase_api.datasets_dir / 'preprocessed_fishbase.csv'}")
        
        if addition_to_db:
            data_db = data['Species', 'FullDescription_en'].combine_first(embeddings_en_df)
            data_db.to_csv(self.fishbase_api.datasets_dir / "fishbase_embeddings.csv", index=False)
            print(f"Dataset for database saved to: {self.fishbase_api.datasets_dir / 'fishbase_embeddings.csv'}")

            #TODO вызвать метод записи в бд из vector_database.py
            
            
        return data

    def add_translation(self, data:pd.DataFrame):
        ...

    def clean_text(self, text:str):
        if text is None or text is np.nan:
            return ''
        nlp = spacy.load("en_core_web_sm")
        
        text = re.sub(r'(nan)', '', text)
        text = re.sub(r'[^\w\s.,;:\/!?()-]', '', text)
        text = re.sub(r" (\(Ref. [0-9, ]*\))", '', text)
            
        doc = nlp(text)
        filtered_text = ' '.join([token.text for token in doc if not token.is_stop])
                
        return filtered_text
    
if __name__=='__main__':
    data_proc = DataProcessor()
    data = data_proc.process_raw_data()
