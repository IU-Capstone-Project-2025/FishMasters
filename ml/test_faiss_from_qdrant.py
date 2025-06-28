#!/usr/bin/env python3
"""
Test script to demonstrate FAISS reading data from Qdrant (no duplication)
"""

import os
import numpy as np
from dotenv import load_dotenv
from faiss_from_qdrant import FaissFromQdrantDatabase
from qwen_embeddings import FishQwenEmbedder, FishSafeEmbedder

# Load environment variables
load_dotenv()


def test_faiss_from_qdrant():
    """Test FAISS built from Qdrant data"""
    
    print("=== FAISS from Qdrant Test ===\n")
    print("This test uses FAISS for fast search while reading data only from Qdrant")
    print("No data duplication - single source of truth in Qdrant\n")
    
    # Initialize database
    try:
        vector_db = FaissFromQdrantDatabase(
            collection_name="fish_embeddings_20250627_102709",
            faiss_index_path="qdrant_faiss_index.faiss"
        )
        
        # Get database stats
        stats = vector_db.get_stats()
        print(f"Database stats:")
        print(f"  Qdrant points: {stats['qdrant_points']}")
        print(f"  FAISS vectors: {stats['faiss_vectors']}")
        print(f"  Index synchronized: {stats['index_synchronized']}")
        print(f"  Collection: {stats['qdrant_collection']}")
        print(f"  FAISS index path: {stats['faiss_index_path']}")
        
        if stats['qdrant_points'] == 0:
            print("\n❌ No fish in Qdrant database. Please run the loader first:")
            print("   python load_fish_embeddings.py --test-run")
            return
        
        if not stats['index_synchronized']:
            print("\n⚠️  FAISS index is not synchronized with Qdrant. Rebuilding...")
            vector_db.rebuild_faiss_index()
            stats = vector_db.get_stats()
            print(f"After rebuild - FAISS vectors: {stats['faiss_vectors']}")
        
        # Generate a random query vector for testing
        print("\n--- Generating random query vector ---")
        query_vector = np.random.rand(1024).tolist()
        print(f"Query vector generated (dimension: {len(query_vector)})")
        
        # Test FAISS search (reads metadata from Qdrant)
        print("\n--- Testing FAISS Search (with Qdrant metadata retrieval) ---")
        faiss_results = vector_db.search(query_vector, top_k=5)
        print(f"FAISS found {len(faiss_results)} results:")
        for i, (fish, score) in enumerate(faiss_results):
            print(f"  {i+1}. {fish.name} (similarity: {score:.4f})")
            print(f"     Genus: {fish.genus}, Species: {fish.species}")
            print(f"     Description: {fish.full_description[:100]}...")
            print()
        
        # Test Qdrant-only search for comparison
        print("\n--- Testing Qdrant-Only Search ---")
        qdrant_results = vector_db.search_qdrant_only(query_vector, top_k=5)
        print(f"Qdrant found {len(qdrant_results)} results:")
        for i, fish in enumerate(qdrant_results):
            print(f"  {i+1}. {fish.name}")
            print(f"     Genus: {fish.genus}, Species: {fish.species}")
            print(f"     Description: {fish.full_description[:100]}...")
            print()
        
        # Benchmark performance
        print("\n--- Performance Benchmark ---")
        benchmark_results = vector_db.benchmark_search(query_vector, top_k=5)
        
        print(f"FAISS search time (includes Qdrant metadata retrieval): {benchmark_results['faiss_time_seconds']:.6f} seconds")
        print(f"Qdrant-only search time: {benchmark_results['qdrant_time_seconds']:.6f} seconds")
        print(f"Performance ratio: {benchmark_results['speedup']:.2f}x")
        print(f"FAISS results: {benchmark_results['faiss_results_count']}")
        print(f"Qdrant results: {benchmark_results['qdrant_results_count']}")
        print(f"Note: {benchmark_results['note']}")
        
        # Multiple benchmark runs for more accurate timing
        print("\n--- Multiple Benchmark Runs (10 iterations) ---")
        faiss_times = []
        qdrant_times = []
        
        for i in range(10):
            # Generate different query each time
            test_query = np.random.rand(1024).tolist()
            benchmark = vector_db.benchmark_search(test_query, top_k=5)
            faiss_times.append(benchmark['faiss_time_seconds'])
            qdrant_times.append(benchmark['qdrant_time_seconds'])
        
        avg_faiss_time = np.mean(faiss_times)
        avg_qdrant_time = np.mean(qdrant_times)
        avg_speedup = avg_qdrant_time / avg_faiss_time if avg_faiss_time > 0 else float('inf')
        
        print(f"Average FAISS time (+ metadata): {avg_faiss_time:.6f} seconds")
        print(f"Average Qdrant-only time: {avg_qdrant_time:.6f} seconds")
        print(f"Average performance ratio: {avg_speedup:.2f}x")
        
        # Test rebuilding FAISS index
        print("\n--- Testing FAISS Index Rebuild ---")
        print("Rebuilding FAISS index from current Qdrant data...")
        vector_db.rebuild_faiss_index()
        new_stats = vector_db.get_stats()
        print(f"After rebuild:")
        print(f"  FAISS vectors: {new_stats['faiss_vectors']}")
        print(f"  Index synchronized: {new_stats['index_synchronized']}")
        
        print("\n✅ FAISS from Qdrant test completed successfully!")
        print("\n📊 Summary:")
        print("  - FAISS provides fast vector similarity search")
        print("  - All data is stored only in Qdrant (no duplication)")
        print("  - Metadata is retrieved from Qdrant when needed")
        print("  - FAISS index can be rebuilt from Qdrant data anytime")
        
    except Exception as e:
        print(f"❌ Error during test: {e}")
        print("\nMake sure you have:")
        print("1. Set up QDRANT_URL and QDRANT_API_KEY in .env file")
        print("2. Loaded some fish embeddings using: python load_fish_embeddings.py --test-run")


def test_index_rebuild():
    """Test rebuilding FAISS index from Qdrant"""
    
    print("\n=== FAISS Index Rebuild Test ===")
    
    try:
        vector_db = FaissFromQdrantDatabase(
            collection_name="fish_embeddings_20250627_102709",
            faiss_index_path="qdrant_faiss_index.faiss"
        )
        
        stats_before = vector_db.get_stats()
        print(f"Before rebuild:")
        print(f"  Qdrant points: {stats_before['qdrant_points']}")
        print(f"  FAISS vectors: {stats_before['faiss_vectors']}")
        print(f"  Synchronized: {stats_before['index_synchronized']}")
        
        if stats_before['qdrant_points'] == 0:
            print("No data in Qdrant to rebuild from.")
            return
        
        print("\nRebuilding FAISS index from Qdrant...")
        vector_db.rebuild_faiss_index()
        
        stats_after = vector_db.get_stats()
        print(f"\nAfter rebuild:")
        print(f"  Qdrant points: {stats_after['qdrant_points']}")
        print(f"  FAISS vectors: {stats_after['faiss_vectors']}")
        print(f"  Synchronized: {stats_after['index_synchronized']}")
        
        print("✅ Index rebuild completed!")
        
    except Exception as e:
        print(f"❌ Error during rebuild test: {e}")


def interactive_search():
    """Interactive search interface"""
    
    print("\n=== Interactive Search ===")
    
    try:
        vector_db = FaissFromQdrantDatabase(
            collection_name="fish_embeddings_20250627_102709",
            faiss_index_path="qdrant_faiss_index.faiss"
        )
        
        stats = vector_db.get_stats()
        if stats['qdrant_points'] == 0:
            print("No fish in database. Please run the loader first.")
            return
        
        print(f"Database contains {stats['qdrant_points']} fish species")
        print("Enter 'q' to quit, 'r' to rebuild FAISS index")
        print("Or press Enter to search with random vector\n")
        
        while True:
            user_input = input("Action (Enter/q/r): ").strip().lower()
            
            if user_input in ['q', 'quit', 'exit']:
                break
            elif user_input in ['r', 'rebuild']:
                print("Rebuilding FAISS index...")
                vector_db.rebuild_faiss_index()
                print("Index rebuilt!")
                continue
            else:
                # Random search
                print("Searching with random vector...")
                query_vector = np.random.rand(1024).tolist()
                
                results = vector_db.search(query_vector, top_k=3)
                print(f"\nTop 3 results:")
                for i, (fish, score) in enumerate(results):
                    print(f"  {i+1}. {fish.name} (similarity: {score:.4f})")
                    print(f"     {fish.genus} {fish.species}")
                print()
        
    except Exception as e:
        print(f"Error during interactive search: {e}")


def choose_embedding_model():
    """Let user choose between safe models and Qwen models"""
    
    print("\n🤖 Choose Embedding Model:")
    print("=" * 40)
    print("1. 🔒 Safe Mode (Recommended for macOS)")
    print("   • Uses lightweight, stable models")
    print("   • No segmentation faults")
    print("   • Fast loading")
    print("   • Good quality embeddings")
    print()
    print("2. ⚡ Qwen Mode (Advanced - may be unstable on some systems)")
    print("   • Attempts to use Qwen3-Embedding-0.6B")
    print("   • Higher quality embeddings (potentially)")
    print("   • May cause crashes on macOS")
    print("   • Slower loading")
    print()
    
    while True:
        try:
            choice = input("Choose mode (1=Safe, 2=Qwen): ").strip()
            
            if choice == "1":
                print("✅ Selected Safe Mode - Using stable lightweight models")
                return "safe"
            elif choice == "2":
                print("⚠️  Selected Qwen Mode - May be unstable on some systems")
                confirm = input("Are you sure? This may cause crashes (y/N): ").strip().lower()
                if confirm in ['y', 'yes']:
                    print("⚡ Proceeding with Qwen Mode")
                    return "qwen"
                else:
                    print("🔒 Switching to Safe Mode")
                    return "safe"
            else:
                print("❌ Invalid choice. Please enter 1 or 2.")
                
        except KeyboardInterrupt:
            print("\n🔒 Defaulting to Safe Mode")
            return "safe"


def text_based_search():
    """Text-based search interface where users can enter manual prompts"""
    
    print("\n=== Text-Based Fish Search CLI ===")
    
    # Choose embedding model first
    model_choice = choose_embedding_model()
    
    try:
        # Get top_k from user at the start
        while True:
            try:
                top_k = int(input("Enter number of top results to return (default 5): ") or "5")
                if top_k > 0:
                    break
                else:
                    print("Please enter a positive number.")
            except ValueError:
                print("Please enter a valid number.")
        
        # Initialize text embedder based on user choice
        if model_choice == "safe":
            print(f"\n🔒 Initializing SAFE text embedding model...")
            print("📥 Using only stable, tested models...")
            
            text_embedder = None
            try:
                text_embedder = FishSafeEmbedder()
                print("✅ Safe text embedder initialized successfully!")
                
            except Exception as e:
                print(f"❌ Failed to initialize safe embedder: {e}")
                print("💡 This should not happen with the safe embedder - it has fallbacks")
                text_embedder = None
            except KeyboardInterrupt:
                print("🛑 Model loading interrupted by user")
                print("💡 Using fallback...")
                text_embedder = None
        
        else:  # qwen mode
            print(f"\n⚡ Initializing QWEN text embedding model...")
            print("📥 This will try Qwen models first, then fallback to safe models...")
            
            text_embedder = None
            try:
                text_embedder = FishQwenEmbedder()
                print("✅ Qwen text embedder initialized successfully!")
                
            except Exception as e:
                print(f"❌ Failed to initialize Qwen embedder: {e}")
                print("💡 This should not happen - Qwen embedder has safe fallbacks")
                text_embedder = None
            except KeyboardInterrupt:
                print("🛑 Model loading interrupted by user")
                print("💡 Using fallback...")
                text_embedder = None
        
        # Initialize the database
        print(f"\n🗄️ Initializing FAISS database...")
        vector_db = FaissFromQdrantDatabase(
            collection_name="fish_embeddings_20250627_102709",
            faiss_index_path="qdrant_faiss_index.faiss"
        )
        
        stats = vector_db.get_stats()
        if stats['qdrant_points'] == 0:
            print("❌ No fish in database. Please run the loader first:")
            print("   python load_fish_embeddings.py")
            return
        
        print(f"✅ Database loaded with {stats['qdrant_points']} fish species")
        print(f"🔍 Will return top {top_k} results for each search")
        
        # Show model info
        if text_embedder:
            model_info = text_embedder.get_model_info()
            print(f"🤖 Text embedding model: {model_info['model_name']}")
            print(f"📏 Model dimension: {model_info['embedding_dimension']} → 1024 (adjusted)")
            print(f"💻 Device: {model_info['device']}")
        else:
            print("⚠️  Using random vectors (text embedder not available)")
        
        print("\nAvailable commands:")
        print("  • Enter any text description to search for similar fish")
        print("  • 'random' - search with random vector")
        print("  • 'stats' - show database statistics") 
        print("  • 'rebuild' - rebuild FAISS index")
        print("  • 'q' or 'quit' - exit")
        print("\nExamples:")
        print("  • 'large predatory fish with sharp teeth'")
        print("  • 'small colorful tropical fish'")
        print("  • 'elongated eel-like fish'")
        print("  • 'shark with spots'")
        
        while True:
            print("\n" + "="*60)
            user_input = input("🐟 Enter search query: ").strip()
            
            if not user_input:
                continue
            
            if user_input.lower() in ['q', 'quit', 'exit']:
                print("👋 Goodbye!")
                break
            elif user_input.lower() == 'random':
                print("🎲 Searching with random vector...")
                query_vector = np.random.rand(1024).tolist()
                search_and_display_results(vector_db, query_vector, top_k, "Random Vector")
            elif user_input.lower() == 'stats':
                display_stats(vector_db)
            elif user_input.lower() == 'rebuild':
                print("🔄 Rebuilding FAISS index...")
                vector_db.rebuild_faiss_index()
                print("✅ Index rebuilt!")
            else:
                # Text-based search using Qwen embeddings
                print(f"🔍 Searching for: '{user_input}'")
                
                if text_embedder:
                    try:
                        print("🤖 Converting text to embedding using Qwen model...")
                        query_vector = text_embedder.encode_fish_query(user_input)
                        print("✅ Text successfully converted to embedding!")
                        search_and_display_results(vector_db, query_vector, top_k, user_input)
                    except Exception as e:
                        print(f"❌ Error during text embedding: {e}")
                        print("🎲 Falling back to random vector...")
                        query_vector = np.random.rand(1024).tolist()
                        search_and_display_results(vector_db, query_vector, top_k, f"{user_input} (random fallback)")
                else:
                    print("⚠️  Text embedder not available, using random vector...")
                    query_vector = np.random.rand(1024).tolist()
                    search_and_display_results(vector_db, query_vector, top_k, f"{user_input} (random)")
        
    except KeyboardInterrupt:
        print("\n👋 Search interrupted. Goodbye!")
    except Exception as e:
        print(f"❌ Error during text search: {e}")


def search_and_display_results(vector_db, query_vector, top_k, query_description):
    """Helper function to search and display results"""
    try:
        print(f"⏳ Searching...")
        results = vector_db.search(query_vector, top_k=top_k)
        
        if not results:
            print("❌ No results found.")
            return
        
        print(f"\n🎯 Top {len(results)} results for: {query_description}")
        print("-" * 80)
        
        for i, (fish, score) in enumerate(results):
            print(f"\n{i+1}. 🐟 {fish.name}")
            print(f"   📊 Similarity: {score:.4f}")
            if fish.genus or fish.species:
                print(f"   🧬 Taxonomy: {fish.genus} {fish.species}")
            if fish.fbname and fish.fbname != fish.name:
                print(f"   🏷️  Common name: {fish.fbname}")
            
            # Display description with word wrapping
            if fish.full_description:
                description = fish.full_description[:200]
                if len(fish.full_description) > 200:
                    description += "..."
                print(f"   📝 Description: {description}")
            print()
        
        print("-" * 80)
        print(f"⚡ Search completed in ~{len(results)} results")
        
    except Exception as e:
        print(f"❌ Error during search: {e}")


def display_stats(vector_db):
    """Display database statistics"""
    try:
        stats = vector_db.get_stats()
        print("\n📊 Database Statistics:")
        print("-" * 40)
        print(f"Qdrant points: {stats['qdrant_points']:,}")
        print(f"FAISS vectors: {stats['faiss_vectors']:,}")
        print(f"Synchronized: {'✅ Yes' if stats['index_synchronized'] else '❌ No'}")
        print(f"Collection: {stats['qdrant_collection']}")
        print(f"Index file: {stats['faiss_index_path']}")
        print("-" * 40)
    except Exception as e:
        print(f"❌ Error getting stats: {e}")


def main():
    """Main function to run tests"""
    
    # Check environment variables
    if not os.getenv("QDRANT_URL") or not os.getenv("QDRANT_API_KEY"):
        print("❌ Missing environment variables!")
        print("Please create a .env file with:")
        print("   QDRANT_URL=https://your-cluster.qdrant.tech")
        print("   QDRANT_API_KEY=your-api-key-here")
        return
    
    print("🐟 Fish Search System")
    print("=" * 50)
    print("Choose an option:")
    print("1. 🔍 Text-based search (NEW - Enter manual search prompts)")
    print("2. 🧪 Run full test suite")
    print("3. 🔄 Test index rebuild")
    print("4. 🎲 Interactive random search")
    print("5. ❌ Exit")
    
    try:
        choice = input("\nEnter your choice (1-5): ").strip()
        
        if choice == "1":
            text_based_search()
        elif choice == "2":
            test_faiss_from_qdrant()
        elif choice == "3":
            test_index_rebuild()
        elif choice == "4":
            interactive_search()
        elif choice == "5":
            print("👋 Goodbye!")
        else:
            print("❌ Invalid choice. Please run again and select 1-5.")
    
    except KeyboardInterrupt:
        print("\n👋 Goodbye!")


if __name__ == "__main__":
    main() 