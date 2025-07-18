from torchvision.models import resnet18, ResNet18_Weights
from torchvision.transforms import Compose, Resize, CenterCrop, ToTensor, Normalize
import torch.nn as nn
import torch
import pandas as pd
import os
import sys
from PIL import Image
import numpy as np
from pathlib import Path
from typing import List, Dict, Tuple, Optional
from dotenv import load_dotenv
from qdrant_client import QdrantClient
from qdrant_client.models import VectorParams, Distance, PointStruct
from tqdm import tqdm
import time
import urllib3
import ssl

# Disable SSL certificate verification and urllib3 warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
ssl._create_default_https_context = ssl._create_unverified_context

# Add parent directory to path to import modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from data_prep import DataProcessor
from fish_species import FishSpecies

# Load environment variables
load_dotenv()

class Embedder:
    def __init__(self):
        # Download ResNet18 with SSL verification disabled
        try:
            print("Downloading ResNet18 pretrained weights...")
            self.encoder = resnet18(weights=ResNet18_Weights.IMAGENET1K_V1)
            self.encoder.fc = nn.Identity()
            self.encoder.eval()  # Set to evaluation mode
            print("✅ ResNet18 loaded successfully")
        except Exception as e:
            print(f"Error loading ResNet18: {e}")
            print("Trying to load without pretrained weights...")
            self.encoder = resnet18(weights=None)
            self.encoder.fc = nn.Identity()
            self.encoder.eval()
            print("⚠️ ResNet18 loaded without pretrained weights")
        
        # Define image preprocessing pipeline matching ResNet18 training
        self.transform = Compose([
            Resize(256),
            CenterCrop(224),
            ToTensor(),
            Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])

    def get_embedding(self, image):
        """
        Get embedding for a single image or batch of images
        
        Args:
            image: PIL Image, torch tensor, or batch of tensors
            
        Returns:
            torch tensor: Image embedding(s)
        """
        with torch.no_grad():
            if isinstance(image, Image.Image):
                # Single PIL image
                image_tensor = self.transform(image).unsqueeze(0)
                return self.encoder(image_tensor).squeeze(0)
            elif isinstance(image, torch.Tensor):
                # Already preprocessed tensor(s)
                if len(image.shape) == 3:
                    # Single image, add batch dimension
                    image = image.unsqueeze(0)
                return self.encoder(image)
            else:
                raise ValueError("Image must be PIL.Image or torch.Tensor")

    def load_and_preprocess_image(self, image_path: str) -> Optional[torch.Tensor]:
        """
        Load and preprocess a single image from file path
        
        Args:
            image_path: Path to image file
            
        Returns:
            Preprocessed image tensor or None if loading fails
        """
        try:
            image = Image.open(image_path).convert('RGB')
            return self.transform(image)
        except Exception as e:
            print(f"Error loading image {image_path}: {e}")
            return None

def pic_from_fishbase(max_images: int = None, download_new: bool = True) -> pd.DataFrame:
    """
    Download pictures of fish from FishBase or load existing ones
    
    Args:
        max_images: Maximum number of images to download (None for all)
        download_new: Whether to download new images or use existing ones
        
    Returns:
        DataFrame with image information including local paths
    """
    print("=== Loading Fish Images ===")
    
    # Initialize data processor
    data_proc = DataProcessor(skip_embedder=True)
    
    # First, always try to load existing data
    output_file = data_proc.fishbase_api.datasets_dir / "fish_data_with_images.csv"
    result_data = pd.DataFrame()
    
    if output_file.exists():
        try:
            result_data = pd.read_csv(output_file)
            print(f"✅ Loaded existing fish data from: {output_file}")
        except Exception as e:
            print(f"⚠️ Error loading existing data: {e}")
    
    # If no existing data or download_new is requested
    if result_data.empty or download_new:
        if download_new:
            print(f"Downloading {'all' if max_images is None else max_images} available images...")
            try:
                # Get raw data for downloading
                raw_data = data_proc.fishbase_api.get_raw_data()
                if raw_data is None:
                    print("Failed to download raw data from FishBase")
                    return pd.DataFrame()
                
                # Select basic columns for processing
                basic_data = raw_data[['Genus', 'Species', 'FBname']].copy()
                
                # Download images
                result_data = data_proc.download_fish_images(
                    basic_data, 
                    max_images=max_images, 
                    delay=0.3  # Be respectful to server
                )
                
                # Save results
                result_data.to_csv(output_file, index=False)
                print(f"Results saved to: {output_file}")
                
            except Exception as e:
                print(f"❌ Error downloading new images: {e}")
                print("💡 Trying to use existing images instead...")
                # Fall back to existing data if download fails
                if output_file.exists():
                    try:
                        result_data = pd.read_csv(output_file)
                        print(f"✅ Using existing data as fallback")
                    except:
                        print("❌ No existing data available")
                        return pd.DataFrame()
        else:
            if result_data.empty:
                print("No existing fish data found. Set download_new=True to download images.")
                return pd.DataFrame()
    
    # Filter to only include fish with successful image downloads
    if 'local_path' in result_data.columns:
        fish_with_images = result_data[
            result_data['local_path'].notna() & 
            (result_data['local_path'] != '')
        ].copy()
        
        print(f"Found {len(fish_with_images)} fish species with downloaded images")
        return fish_with_images
    else:
        print("No local image paths found in the data")
        return pd.DataFrame()

def pic_embeddings_to_qdrant(image_embeddings: List[Tuple[np.ndarray, FishSpecies]], 
                           collection_name: str = "fish_image_embeddings"):
    """
    Upload image embeddings to Qdrant vector database
    
    Args:
        image_embeddings: List of (embedding_vector, fish_species) tuples
        collection_name: Name of the Qdrant collection to create/use
    """
    print(f"=== Uploading {len(image_embeddings)} Image Embeddings to Qdrant ===")
    
    # Get Qdrant credentials
    qdrant_url = os.getenv("QDRANT_URL")
    qdrant_api_key = os.getenv("QDRANT_API_KEY")
    
    if not qdrant_url or not qdrant_api_key:
        raise ValueError("QDRANT_URL and QDRANT_API_KEY environment variables must be set")
    
    # Initialize Qdrant client
    client = QdrantClient(url=qdrant_url, api_key=qdrant_api_key)
    
    # Create collection if it doesn't exist
    try:
        collections = client.get_collections()
        collection_names = [col.name for col in collections.collections]
        
        if collection_name not in collection_names:
            # Determine embedding dimension from first embedding
            embedding_dim = len(image_embeddings[0][0]) if image_embeddings else 512
            
            client.create_collection(
                collection_name=collection_name,
                vectors_config=VectorParams(size=embedding_dim, distance=Distance.COSINE)
            )
            print(f"Created new collection: {collection_name}")
        else:
            print(f"Using existing collection: {collection_name}")
    except Exception as e:
        print(f"Error initializing collection: {e}")
        return
    
    # Upload embeddings in batches
    batch_size = 100
    total_uploaded = 0
    
    for i in tqdm(range(0, len(image_embeddings), batch_size), desc="Uploading batches"):
        batch = image_embeddings[i:i + batch_size]
        points = []
        
        for j, (embedding, fish_species) in enumerate(batch):
            point_id = i + j + 1
            
            # Create payload with fish metadata and image info
            payload = fish_species.to_dict()
            payload.update({
                "data_type": "image_embedding",
                "embedding_model": "resnet18",
                "image_processed_at": time.strftime("%Y-%m-%d %H:%M:%S")
            })
            
            point = PointStruct(
                id=point_id,
                vector=embedding.tolist() if isinstance(embedding, np.ndarray) else embedding,
                payload=payload
            )
            points.append(point)
        
        try:
            client.upsert(collection_name=collection_name, points=points)
            total_uploaded += len(points)
            print(f"Uploaded batch {i//batch_size + 1}: {len(points)} embeddings")
        except Exception as e:
            print(f"Error uploading batch {i//batch_size + 1}: {e}")
    
    print(f"Successfully uploaded {total_uploaded} image embeddings to collection '{collection_name}'")

def pipeline(max_images: int = None, collection_name: str = "fish_image_embeddings", 
            download_new: bool = False):
    """
    Complete pipeline: download images, generate embeddings, upload to Qdrant
    
    Args:
        max_images: Maximum number of images to process (None for all)
        collection_name: Name of Qdrant collection for image embeddings
        download_new: Whether to download new images or use existing ones
    """
    print("=== Fish Image Processing Pipeline ===")
    
    # Step 1: Download/load fish images
    fish_data = pic_from_fishbase(max_images=max_images, download_new=download_new)
    
    if fish_data.empty:
        print("No fish data with images available. Exiting.")
        return
    
    # Step 2: Initialize embedder
    print("Initializing image embedder...")
    embedder = Embedder()
    
    # Step 3: Process images and generate embeddings
    print("Processing images and generating embeddings...")
    image_embeddings = []
    failed_images = []
    
    # Images are saved in the current working directory structure
    # Since DataProcessor saves images relative to current directory,
    # we need to look in the correct location
    current_dir = Path('.').resolve()
    
    for idx, row in tqdm(fish_data.iterrows(), total=len(fish_data), desc="Processing images"):
        try:
            # Handle multiple image paths (separated by ';')
            image_paths = str(row['local_path']).split(';') if pd.notna(row['local_path']) else []
            
            for image_path in image_paths:
                image_path = image_path.strip()
                if not image_path:
                    continue
                
                # Handle different path formats
                if os.path.isabs(image_path):
                    # Absolute path - use as is
                    full_image_path = Path(image_path)
                else:
                    # For relative paths, try multiple locations since images might be saved 
                    # in different places depending on where the script was run
                    potential_paths = [
                        # In current directory (pic_verification/datasets/...)
                        current_dir / image_path,
                        # In parent directory (ml/datasets/...)
                        current_dir.parent / image_path,
                        # If path doesn't start with datasets/, try adding it
                        current_dir / 'datasets' / image_path,
                        current_dir.parent / 'datasets' / image_path
                    ]
                    
                    full_image_path = None
                    for potential_path in potential_paths:
                        if potential_path.exists():
                            full_image_path = potential_path
                            break
                    
                    if full_image_path is None:
                        # Couldn't find the image in any of the expected locations
                        failed_images.append(f"File not found in any expected location: {image_path}")
                        continue
                
                # Load and preprocess image
                image_tensor = embedder.load_and_preprocess_image(str(full_image_path))
                if image_tensor is None:
                    failed_images.append(f"Failed to load: {full_image_path}")
                    continue
                
                # Generate embedding
                embedding = embedder.get_embedding(image_tensor.unsqueeze(0))
                embedding_np = embedding.squeeze(0).cpu().numpy()
                
                # Create FishSpecies object with image-specific ID
                fish_id = len(image_embeddings) + 1
                fish_species = FishSpecies(
                    fish_id=fish_id,
                    name=f"{row['Genus']}_{row['Species']}",
                    genus=row['Genus'] if pd.notna(row['Genus']) else '',
                    species=row['Species'] if pd.notna(row['Species']) else '',
                    fbname=row['FBname'] if pd.notna(row['FBname']) else '',
                    full_description=f"Image of {row['Genus']} {row['Species']} ({row['FBname']})"
                )
                
                # Add image path to the species object
                fish_species.image_path = str(full_image_path)
                
                image_embeddings.append((embedding_np, fish_species))
        
        except Exception as e:
            failed_images.append(f"Error processing {row.get('Genus', 'Unknown')} {row.get('Species', 'Unknown')}: {e}")
    
    print(f"Successfully processed {len(image_embeddings)} images")
    if failed_images:
        print(f"Failed to process {len(failed_images)} images:")
        for failure in failed_images[:10]:  # Show first 10 failures
            print(f"  {failure}")
        if len(failed_images) > 10:
            print(f"  ... and {len(failed_images) - 10} more")
    
    # Step 4: Upload to Qdrant
    if image_embeddings:
        pic_embeddings_to_qdrant(image_embeddings, collection_name)
        print(f"Pipeline completed successfully! Processed {len(image_embeddings)} fish images.")
    else:
        print("No embeddings generated. Pipeline failed.")

if __name__ == "__main__":
    # Example usage
    import argparse
    
    parser = argparse.ArgumentParser(description='Fish Image Processing Pipeline')
    parser.add_argument('--max-images', type=int, default=None, 
                       help='Maximum number of images to process (default: all)')
    parser.add_argument('--collection-name', type=str, default='fish_image_embeddings',
                       help='Qdrant collection name for image embeddings')
    parser.add_argument('--download-new', action='store_true',
                       help='Download new images from FishBase (default: use existing)')
    parser.add_argument('--test-run', action='store_true',
                       help='Process only first 10 images for testing')
    
    args = parser.parse_args()
    
    if args.test_run:
        args.max_images = 10
        print("Running in test mode: processing only 10 images")
    
    # Run the pipeline
    pipeline(
        max_images=args.max_images,
        collection_name=args.collection_name,
        download_new=args.download_new
    )