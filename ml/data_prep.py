import requests
from io import BytesIO
import urllib3
import numpy as np
import pandas as pd 
from llama_cpp import Llama
from transformers import pipeline 
import os
from pathlib import Path 

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
            print(f"✅ Successfully downloaded {len(species_df)} records of fish species!")
            
            # Сохраняем в CSV    
            self.datasets_dir.mkdir(exist_ok=True, parents=True)
        
            output_file = self.datasets_dir / "raw_fishbase.csv"
            species_df.to_csv(output_file, index=False)
            print(f"💾 Downloaded data saved in: {output_file}")
            
            return pd.read_csv(output_file)
        
        except Exception as e:
            print(f"❌ Error: {e}")
            return None

class DataProcessor:
    def __init__(self):
        self.fishbase_api = FishBaseAPI()
        self.translator = pipeline(
            'translation_en_to_ru',
            model = "Helsinki-NLP/opus-mt-en-ru"
        )
        # self.translator = pipeline(
        #     "translation",
        #     model="facebook/nllb-200-distilled-600M",
        #     src_lang="eng_Latin",
        #     tgt_lang="rus_Cyrl"
        # )
        self.embedder = Llama.from_pretrained(
            repo_id="Qwen/Qwen3-Embedding-0.6B-GGUF",
            filename="Qwen3-Embedding-0.6B-Q8_0.gguf",
            embedding=True
        )
        
    def process_raw_data(self, translation: bool = False):
        raw_data = self.fishbase_api.get_raw_data()
        # raw_data = pd.read_csv('./datasets/raw_fishbase.csv')
        
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
        data['AirBreathing'] = data['AirBreathing'].apply(lambda x: fix_air_breathing[x])

        #added new column to save the description for embeddings
        data['FullDescription_en'] = data.apply(
            lambda row: f"{row['Species']}(aka {row['FBname']}; Genus-{row['Genus']}): has {row['BodyShapeI']} bodyshape, common length {row['Length']} and weight {row['Weight']}, live up to {row['LongevityWild']} years; Assumed {row['AirBreathing']} breathing, {row['Dangerous']} for human. Lives in {row['Fresh'] * 'fresh ' + row['Brack'] * 'brack ' + row['Saltwater']*'salt '}water common depth {row['DepthRangeShallow']}-{row['DepthRangeDeep']} metres. Main catching method is {row["MainCatchingMethod"]}. Additional comments: {row['Comments']}",
            axis=1
        )
        
        data['Embedding_en'] = data['FullDescription_en'].apply(lambda x: self.embedder.create_embedding(x)['data'][0]['embedding'][0])
        
        if translation:
            self.add_translation(data)
        
        data.to_csv(self.fishbase_api.datasets_dir / "preprocessed_fishbase.csv")
        
        return data
        
    def add_translation(self, data:pd.DataFrame):
        ...
        
if __name__ == "__main__":
    data_proc = DataProcessor()
    data = data_proc.process_raw_data()