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
import time

class FishBaseAPI:
    def __init__(self):
        self.base_url = "https://fishbase.ropensci.org/fishbase"
        self.datasets_dir = Path('./datasets')
        self.images_dir = Path('./datasets/fish_images')
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
    def __init__(self, skip_embedder: bool = False):
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
        if not skip_embedder:
            self.embedder = SentenceTransformer(
                "Qwen/Qwen3-Embedding-0.6B",
                model_kwargs={"attn_implementation":"eager", "device_map": "auto"},
                tokenizer_kwargs={"padding_side": "left"}
            )
        else:
            self.embedder = None

    def download_fish_images(self, data: pd.DataFrame, max_images: int = None, delay: float = 0.5) -> pd.DataFrame:
        """
        Download fish images from FishBase for species that have image filenames.
        
        Args:
            data: DataFrame containing species data with image filename columns
            max_images: Maximum number of images to download (None for all)
            delay: Delay between downloads in seconds to be respectful to the server
            
        Returns:
            DataFrame with additional 'image_path' column containing local image paths
        """
        print("5. Downloading fish images...")
        
        # Create images directory
        self.fishbase_api.images_dir.mkdir(exist_ok=True, parents=True)
        
        # Get species with image data from the raw data (we need to fetch it again to get image columns)
        raw_data = self.fishbase_api.get_raw_data()
        
        # Image-related columns we found: PicPreferredName, Pic, PictureFemale, LarvaPic, EggPic
        image_columns = ['PicPreferredName', 'Pic', 'PictureFemale', 'LarvaPic', 'EggPic']
        
        # Filter species that have at least one image
        species_with_images = raw_data[
            raw_data[image_columns].notna().any(axis=1)
        ][['SpecCode', 'Genus', 'Species'] + image_columns].copy()
        
        if max_images:
            species_with_images = species_with_images.head(max_images)
        
        print(f"Found {len(species_with_images)} species with potential images")
        
        # Base URLs to try for images
        base_urls = [
            "https://fishbase.org/images/species/",
            "https://www.fishbase.org/images/species/"
        ]
        
        downloaded_images = []
        
        tqdm.pandas(desc="Downloading images")
        
        for idx, row in tqdm(species_with_images.iterrows(), total=len(species_with_images), desc="Downloading images"):
            genus = row['Genus']
            species = row['Species']
            spec_code = row['SpecCode']
            
            # Try each image column
            for img_col in image_columns:
                img_filename = row[img_col]
                
                if pd.notna(img_filename) and img_filename:
                    # Clean filename (remove any path separators)
                    img_filename = os.path.basename(str(img_filename))
                    
                    # Create local filename with species info
                    file_extension = os.path.splitext(img_filename)[1] or '.jpg'
                    local_filename = f"{genus}_{species}_{spec_code}_{img_col}{file_extension}"
                    local_path = self.fishbase_api.images_dir / local_filename
                    
                    # Skip if already downloaded
                    if local_path.exists():
                        downloaded_images.append({
                            'SpecCode': spec_code,
                            'Genus': genus,
                            'Species': species,
                            'image_type': img_col,
                            'original_filename': img_filename,
                            'local_path': str(local_path),
                            'download_status': 'already_exists'
                        })
                        continue
                    
                    # Try downloading from each base URL
                    downloaded = False
                    for base_url in base_urls:
                        try:
                            img_url = base_url + img_filename
                            response = requests.get(img_url, timeout=10, verify=False)
                            
                            if response.status_code == 200:
                                # Save the image
                                with open(local_path, 'wb') as f:
                                    f.write(response.content)
                                
                                downloaded_images.append({
                                    'SpecCode': spec_code,
                                    'Genus': genus,
                                    'Species': species,
                                    'image_type': img_col,
                                    'original_filename': img_filename,
                                    'local_path': str(local_path),
                                    'download_status': 'success',
                                    'source_url': img_url
                                })
                                
                                downloaded = True
                                break
                                
                        except Exception as e:
                            continue
                    
                    if not downloaded:
                        downloaded_images.append({
                            'SpecCode': spec_code,
                            'Genus': genus,
                            'Species': species,
                            'image_type': img_col,
                            'original_filename': img_filename,
                            'local_path': None,
                            'download_status': 'failed'
                        })
            
            # Be respectful to the server
            time.sleep(delay)
        
        # Create DataFrame with download results
        download_results = pd.DataFrame(downloaded_images)
        
        if not download_results.empty:
            # Save download log
            download_log_path = self.fishbase_api.datasets_dir / "image_download_log.csv"
            download_results.to_csv(download_log_path, index=False)
            
            # Print statistics
            successful_downloads = len(download_results[download_results['download_status'] == 'success'])
            already_exists = len(download_results[download_results['download_status'] == 'already_exists'])
            failed_downloads = len(download_results[download_results['download_status'] == 'failed'])
            
            print(f"Image download complete:")
            print(f"  Successfully downloaded: {successful_downloads}")
            print(f"  Already existed: {already_exists}")
            print(f"  Failed downloads: {failed_downloads}")
            print(f"  Download log saved to: {download_log_path}")
            
            # Add image path information to the original data
            # Create a mapping of SpecCode to image paths for successful downloads
            success_downloads = download_results[download_results['download_status'].isin(['success', 'already_exists'])]
            if not success_downloads.empty:
                # Group by SpecCode and collect all image paths
                image_paths_by_species = success_downloads.groupby(['Genus', 'Species']).agg({
                    'local_path': lambda x: '; '.join(x.dropna())
                }).reset_index()
                
                # Merge with original data
                data = data.merge(
                    image_paths_by_species, 
                    on=['Genus', 'Species'], 
                    how='left'
                )
                data['local_path'] = data['local_path'].fillna('')
        else:
            print("No images were downloaded")
            data['local_path'] = ''
        
        return data

    def process_raw_data(self, translation: bool = False, addition_to_db: bool = False, download_images: bool = False, max_images: int = None):
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

        if self.embedder is not None:
            print("4. Generating embeddings...")
            embeddings_en = self.embedder.encode(
                data['cleaned_discription'],
                convert_to_numpy=True,
                show_progress_bar=True,
                batch_size=32
            )
            
            embeddings_en_df = pd.DataFrame(embeddings_en)
            
            full_data = data.combine_first(embeddings_en_df)
        else:
            print("4. Skipping embeddings generation...")
            full_data = data.copy()

        # Download images if requested
        if download_images:
            full_data = self.download_fish_images(full_data, max_images=max_images)

        if translation:
            self.add_translation(data)
        
        full_data.to_csv(self.fishbase_api.datasets_dir / "preprocessed_fishbase.csv")
        print(f"Preprocessed dataset saved to: {self.fishbase_api.datasets_dir / 'preprocessed_fishbase.csv'}")
        
        if addition_to_db:
            data_db = data['Species', 'FullDescription_en'].combine_first(embeddings_en_df)
            data_db.to_csv(self.fishbase_api.datasets_dir / "fishbase_embeddings.csv", index=False)
            print(f"Dataset for database saved to: {self.fishbase_api.datasets_dir / 'fishbase_embeddings.csv'}")

            #TODO вызвать метод записи в бд из vector_database.py
            
            
        return full_data

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
    # Process data with image downloading enabled
    # max_images=10 limits downloads for testing - set to None for all images
    data = data_proc.process_raw_data(download_images=True, max_images=10)
