#!/usr/bin/env python3
"""
Example script demonstrating fish image downloading from FishBase.

This script shows how to:
1. Download fish species data from FishBase
2. Download images for fish species that have image files
3. Save the results and create a download log

Usage:
    python example_image_download.py [--max-images N] [--delay SECONDS]
"""

import argparse
from data_prep import DataProcessor
import pandas as pd
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(description='Download fish images from FishBase')
    parser.add_argument('--max-images', type=int, default=50, 
                       help='Maximum number of images to download (default: 50, use 0 for all)')
    parser.add_argument('--delay', type=float, default=0.5,
                       help='Delay between downloads in seconds (default: 0.5)')
    parser.add_argument('--no-embeddings', action='store_true',
                       help='Skip generating embeddings (faster for image-only downloads)')
    
    args = parser.parse_args()
    
    print("=== Fish Image Download Example ===")
    print(f"Max images: {'All' if args.max_images == 0 else args.max_images}")
    print(f"Delay between downloads: {args.delay}s")
    print()
    
    # Initialize data processor
    data_proc = DataProcessor(skip_embedder=args.no_embeddings)
    
    if args.no_embeddings:
        # Download only images without full processing
        print("Downloading images only (no embeddings)...")
        
        # Get raw data
        raw_data = data_proc.fishbase_api.get_raw_data()
        basic_data = raw_data[['Genus', 'Species', 'FBname']].copy()
        
        # Download images
        max_imgs = None if args.max_images == 0 else args.max_images
        result_data = data_proc.download_fish_images(basic_data, max_images=max_imgs, delay=args.delay)
        
        # Save results
        output_file = data_proc.fishbase_api.datasets_dir / "fish_data_with_images.csv"
        result_data.to_csv(output_file, index=False)
        print(f"Results saved to: {output_file}")
        
    else:
        # Full processing with embeddings and images
        print("Full processing with embeddings and images...")
        max_imgs = None if args.max_images == 0 else args.max_images
        data = data_proc.process_raw_data(
            download_images=True, 
            max_images=max_imgs
        )
        print("Full processing complete!")
    
    # Show some statistics about downloaded images
    images_dir = data_proc.fishbase_api.images_dir
    if images_dir.exists():
        image_files = list(images_dir.glob('*.*'))
        print(f"\nTotal images downloaded: {len(image_files)}")
        
        # Show some examples
        if image_files:
            print("\nExample downloaded images:")
            for img_file in image_files[:5]:
                print(f"  {img_file.name}")
            if len(image_files) > 5:
                print(f"  ... and {len(image_files) - 5} more")
    
    # Show download log if it exists
    log_file = data_proc.fishbase_api.datasets_dir / "image_download_log.csv"
    if log_file.exists():
        print(f"\nDownload log available at: {log_file}")
        
        # Read and show summary
        log_df = pd.read_csv(log_file)
        status_counts = log_df['download_status'].value_counts()
        print("Download status summary:")
        for status, count in status_counts.items():
            print(f"  {status}: {count}")

if __name__ == '__main__':
    main() 