#!/usr/bin/env python3
"""
Example script to run the fish image processing pipeline.

This script demonstrates how to:
1. Download fish images from FishBase (or use existing ones)
2. Generate embeddings using ResNet18
3. Upload embeddings to Qdrant vector database

Usage:
    # Test with existing images (process first 5 images)
    python run_image_pipeline.py --test-run

    # Process all existing images
    python run_image_pipeline.py

    # Download new images and process them (up to 50 images)
    python run_image_pipeline.py --download-new --max-images 50

    # Use custom collection name
    python run_image_pipeline.py --collection-name my_fish_images
"""

import os
import sys
from dotenv import load_dotenv

# Add the current directory to Python path to import embedder
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from embedder import pipeline

def main():
    # Load environment variables
    load_dotenv()
    
    # Check if required environment variables are set
    if not os.getenv("QDRANT_URL") or not os.getenv("QDRANT_API_KEY"):
        print("ERROR: Missing required environment variables!")
        print("Please set QDRANT_URL and QDRANT_API_KEY in your .env file or environment.")
        print("\nExample .env file:")
        print("QDRANT_URL=https://your-cluster.qdrant.tech")
        print("QDRANT_API_KEY=your-api-key-here")
        return 1
    
    print("🐟 Fish Image Processing Pipeline 🐟")
    print("====================================")
    
    # Get user choice
    print("\nChoose an option:")
    print("1. Test run (process first 5 images from existing downloads)")
    print("2. Process all existing images")
    print("3. Download new images and process them")
    print("4. Exit")
    
    choice = input("\nEnter your choice (1-4): ").strip()
    
    if choice == "1":
        print("\n🧪 Running test mode...")
        pipeline(
            max_images=5,
            collection_name="fish_image_embeddings_test",
            download_new=False
        )
    
    elif choice == "2":
        print("\n🔄 Processing all existing images...")
        pipeline(
            max_images=None,
            collection_name="fish_image_embeddings",
            download_new=False
        )
    
    elif choice == "3":
        max_images_str = input("\nEnter max number of images to download (or press Enter for all): ").strip()
        max_images = None
        if max_images_str:
            try:
                max_images = int(max_images_str)
            except ValueError:
                print("Invalid number, using all images.")
        
        print(f"\n⬇️ Downloading and processing {'all' if max_images is None else max_images} images...")
        pipeline(
            max_images=max_images,
            collection_name="fish_image_embeddings",
            download_new=True
        )
    
    elif choice == "4":
        print("👋 Goodbye!")
        return 0
    
    else:
        print("❌ Invalid choice. Please run the script again.")
        return 1
    
    print("\n✅ Pipeline completed! Your fish image embeddings are now in Qdrant.")
    print("💡 You can now use these embeddings for image-based fish search and identification.")
    
    return 0

if __name__ == "__main__":
    sys.exit(main()) 