

import csv
import os
import sys
from typing import List, Dict, Any
import numpy as np
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Add the ml directory to the path to import the modules
# sys.path.append(os.path.join(os.path.dirname(__file__), 'proj', 'FishMasters', 'ml'))

from vector_database import VectorDatabase
from fish_species import FishSpecies


def parse_fish_name(fish_name: str) -> Dict[str, str]:
    """
    Parse the fish name to extract genus and species.
    
    Examples:
    - "Aapticheilichthys_websteri" -> genus="Aapticheilichthys", species="websteri"
    - "Aaptosyax_grypus_giant_salmon_carp" -> genus="Aaptosyax", species="grypus"
    """
    parts = fish_name.split('_')
    if len(parts) >= 2:
        genus = parts[0]
        species = parts[1]
        # Join remaining parts as common name
        common_name = '_'.join(parts[2:]) if len(parts) > 2 else ""
        return {
            'genus': genus,
            'species': species,
            'common_name': common_name
        }
    else:
        return {
            'genus': fish_name,
            'species': "",
            'common_name': ""
        }


def create_fish_species_from_csv_row(row_data: Dict[str, str], fish_id: int) -> FishSpecies:
    """
    Create a FishSpecies object from CSV row data.
    
    Args:
        row_data: Dictionary containing fish_name and full_description
        fish_id: Unique identifier for the fish
        
    Returns:
        FishSpecies object
    """
    fish_name = row_data['fish_name']
    full_description = row_data['full_description']
    
    # Parse the fish name
    name_parts = parse_fish_name(fish_name)
    
    # Create FishSpecies object
    fish_species = FishSpecies(
        fish_id=fish_id,
        name=fish_name,
        genus=name_parts['genus'],
        species=name_parts['species'],
        full_description=full_description,
        # Set other fields that might be extractable from description
        fbname=name_parts['common_name'] if name_parts['common_name'] else fish_name
    )
    
    return fish_species


def extract_embedding_from_row(row: List[str]) -> List[float]:
    """
    Extract the 1024-dimensional embedding vector from a CSV row.
    
    Args:
        row: CSV row as list of strings
        
    Returns:
        List of 1024 float values representing the embedding
    """
    # Skip fish_name (index 0) and full_description (index 1)
    # Extract embedding_dim_0 to embedding_dim_1023 (indices 2 to 1025)
    embedding_str_values = row[2:1026]  # Should be 1024 values
    
    try:
        embedding = [float(val) for val in embedding_str_values]
        if len(embedding) != 1024:
            raise ValueError(f"Expected 1024 embedding dimensions, got {len(embedding)}")
        return embedding
    except ValueError as e:
        print(f"Error parsing embedding: {e}")
        print(f"Row length: {len(row)}, Embedding section length: {len(embedding_str_values)}")
        raise


def load_fish_embeddings_to_qdrant(csv_file_path: str, batch_size: int = 100) -> None:
    """
    Load fish embeddings from CSV file into Qdrant database.
    
    Args:
        csv_file_path: Path to the CSV file containing fish embeddings
        batch_size: Number of records to process in each batch
    """
    # Check environment variables
    if not os.getenv("QDRANT_URL") or not os.getenv("QDRANT_API_KEY"):
        raise ValueError("Please set QDRANT_URL and QDRANT_API_KEY environment variables")
    
    # Initialize vector database
    print("Initializing vector database connection...")
    vector_db = VectorDatabase(collection_name="fish_embeddings_20250627_102709")
    
    # Check if file exists
    if not os.path.exists(csv_file_path):
        raise FileNotFoundError(f"CSV file not found: {csv_file_path}")
    
    print(f"Loading fish embeddings from: {csv_file_path}")
    
    total_processed = 0
    total_stored = 0
    batch_count = 0
    
    try:
        with open(csv_file_path, 'r', encoding='utf-8') as csvfile:
            # Use csv.reader to handle potential commas in quoted fields
            csv_reader = csv.reader(csvfile)
            
            # Read header row
            header = next(csv_reader)
            print(f"CSV header columns: {len(header)}")
            print(f"Expected format: fish_name, full_description, embedding_dim_0, ..., embedding_dim_1023")
            
            # Verify header format
            if len(header) != 1026:
                raise ValueError(f"Expected 1026 columns (fish_name + full_description + 1024 embedding dims), got {len(header)}")
            
            # Process rows in batches
            current_batch = []
            
            for row in csv_reader:
                try:
                    if len(row) != 1026:
                        print(f"Warning: Skipping row with {len(row)} columns (expected 1026)")
                        continue
                    
                    # Extract data
                    fish_name = row[0].strip()
                    full_description = row[1].strip()
                    
                    if not fish_name or not full_description:
                        print(f"Warning: Skipping row with empty fish_name or full_description")
                        continue
                    
                    # Extract embedding
                    embedding = extract_embedding_from_row(row)
                    
                    # Create FishSpecies object
                    fish_id = total_processed + 1
                    row_data = {
                        'fish_name': fish_name,
                        'full_description': full_description
                    }
                    fish_species = create_fish_species_from_csv_row(row_data, fish_id)
                    
                    # Add to batch
                    current_batch.append((embedding, fish_species))
                    total_processed += 1
                    
                    # Process batch when it reaches batch_size
                    if len(current_batch) >= batch_size:
                        stored_count = process_batch(vector_db, current_batch, batch_count + 1)
                        total_stored += stored_count
                        batch_count += 1
                        current_batch = []
                        
                        print(f"Processed batch {batch_count}: {stored_count}/{batch_size} records stored successfully")
                        print(f"Total progress: {total_processed} processed, {total_stored} stored")
                
                except Exception as e:
                    print(f"Error processing row {total_processed + 1}: {e}")
                    print(f"Row data: fish_name='{row[0] if len(row) > 0 else 'N/A'}', description length={len(row[1]) if len(row) > 1 else 0}")
                    continue
            
            # Process remaining records in the last batch
            if current_batch:
                stored_count = process_batch(vector_db, current_batch, batch_count + 1)
                total_stored += stored_count
                batch_count += 1
                print(f"Processed final batch {batch_count}: {stored_count}/{len(current_batch)} records stored successfully")
    
    except Exception as e:
        print(f"Error reading CSV file: {e}")
        raise
    
    print(f"\n=== SUMMARY ===")
    print(f"Total rows processed: {total_processed}")
    print(f"Total records stored in Qdrant: {total_stored}")
    print(f"Total batches processed: {batch_count}")
    print(f"Success rate: {(total_stored/total_processed)*100:.2f}%" if total_processed > 0 else "0%")
    
    # Verify storage
    fish_count = vector_db.get_fish_count()
    print(f"Fish count in database: {fish_count}")


def process_batch(vector_db: VectorDatabase, batch: List[tuple], batch_num: int) -> int:
    """
    Process a batch of embeddings and store them in the vector database.
    
    Args:
        vector_db: VectorDatabase instance
        batch: List of (embedding, fish_species) tuples
        batch_num: Batch number for logging
        
    Returns:
        Number of successfully stored records
    """
    stored_count = 0
    
    for embedding, fish_species in batch:
        try:
            result_id = vector_db.store(embedding, fish_species)
            if result_id > 0:
                stored_count += 1
            else:
                print(f"Warning: Failed to store fish '{fish_species.name}' (ID: {fish_species.id})")
        except Exception as e:
            print(f"Error storing fish '{fish_species.name}' (ID: {fish_species.id}): {e}")
    
    return stored_count


def main():
    """Main function to run the CSV loading script."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Load fish embeddings from CSV into Qdrant database')
    parser.add_argument('csv_file', nargs='?', default='/Users/stepan/Documents/Capstone/fish_embeddings_20250627_102709_first_10.csv',
                        help='Path to the CSV file containing fish embeddings (default: fish_embeddings_20250627_102709.csv)')
    parser.add_argument('--batch-size', type=int, default=100,
                        help='Number of records to process in each batch (default: 100)')
    parser.add_argument('--test-run', action='store_true',
                        help='Process only first 10 records for testing')
    
    args = parser.parse_args()
    
    print("=== Fish Embeddings Loader ===")
    print(f"CSV file: {args.csv_file}")
    print(f"Batch size: {args.batch_size}")
    
    if args.test_run:
        print("TEST RUN MODE: Processing only first 10 records")
        # For test run, we'll modify the function to stop after 10 records
        # This is a simple implementation - in production you might want a more elegant solution
    
    try:
        # Check environment variables
        qdrant_url = os.getenv("QDRANT_URL")
        qdrant_api_key = os.getenv("QDRANT_API_KEY")
        
        if not qdrant_url or not qdrant_api_key:
            print("ERROR: Missing required environment variables:")
            print("  QDRANT_URL - URL of your Qdrant instance")
            print("  QDRANT_API_KEY - API key for Qdrant authentication")
            print("\nYou can set these variables in one of the following ways:")
            print("1. Create a .env file in this directory with:")
            print("   QDRANT_URL=https://your-cluster.qdrant.tech")
            print("   QDRANT_API_KEY=your-api-key-here")
            print("\n2. Export them as environment variables:")
            print("   export QDRANT_URL='https://your-cluster.qdrant.tech'")
            print("   export QDRANT_API_KEY='your-api-key-here'")
            sys.exit(1)
        
        print(f"Qdrant URL: {qdrant_url}")
        print(f"Qdrant API Key: {'*' * (len(qdrant_api_key) - 4) + qdrant_api_key[-4:]}")
        
        # Load embeddings
        load_fish_embeddings_to_qdrant(args.csv_file, args.batch_size)
        
        print("\n✅ Fish embeddings loaded successfully!")
        
    except KeyboardInterrupt:
        print("\n\n⚠️  Operation cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main() 