#!/usr/bin/env python3
"""
Test script to demonstrate FAISS reading data from Qdrant (no duplication)
"""

import os
import numpy as np
from dotenv import load_dotenv
from faiss_from_qdrant import FaissFromQdrantDatabase
from qwen_embeddings import QwenEmbedder

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
        faiss_results, faiss_timing = vector_db.search_with_timing(query_vector, top_k=5)
        print(f"FAISS found {len(faiss_results)} results:")
        for i, (fish, score) in enumerate(faiss_results):
            print(f"  {i+1}. {fish.name} (similarity: {score:.4f})")
            print(f"     Genus: {fish.genus}, Species: {fish.species}")
            print(f"     Description: {fish.full_description[:100]}...")
            print()
        
        # Display timing for FAISS search
        display_timing_info(faiss_timing, "FAISS + Qdrant")
        
        # Test Qdrant-only search for comparison
        print("\n--- Testing Qdrant-Only Search ---")
        qdrant_results, qdrant_timing = vector_db.search_qdrant_only_with_timing(query_vector, top_k=5)
        print(f"Qdrant found {len(qdrant_results)} results:")
        for i, fish in enumerate(qdrant_results):
            print(f"  {i+1}. {fish.name}")
            print(f"     Genus: {fish.genus}, Species: {fish.species}")
            print(f"     Description: {fish.full_description[:100]}...")
            print()
        
        # Display timing for Qdrant search
        display_timing_info(qdrant_timing, "Qdrant Only")
        
        # Performance Comparison using detailed timing
        print("\n--- Performance Comparison ---")
        print("Comparing detailed timing breakdown between FAISS+Qdrant vs Qdrant-only:")
        print()
        
        faiss_total = faiss_timing.get('total_time', 0)
        qdrant_total = qdrant_timing.get('total_time', 0)
        speedup = qdrant_total / faiss_total if faiss_total > 0 else float('inf')
        
        print(f"🏁 FAISS + Qdrant total time:    {faiss_total:.6f} seconds")
        print(f"🏁 Qdrant-only total time:       {qdrant_total:.6f} seconds")
        print(f"🚀 Performance ratio:            {speedup:.2f}x {'(FAISS faster)' if speedup > 1 else '(Qdrant faster)'}")
        print()
        
        # Detailed breakdown comparison
        print("📊 Component Comparison:")
        print(f"   FAISS index search:           {faiss_timing.get('faiss_index_search', 0):.6f}s")
        print(f"   vs Qdrant built-in search:    {qdrant_timing.get('qdrant_search_with_metadata', 0):.6f}s")
        print()
        print(f"   FAISS metadata retrieval:     {faiss_timing.get('qdrant_metadata_retrieval', 0):.6f}s")
        print(f"   (included in Qdrant search above)")
        print()
        
        # Multiple benchmark runs for more accurate timing
        print("\n--- Multiple Benchmark Runs (5 iterations) ---")
        print("Running multiple searches for statistical accuracy...")
        
        faiss_total_times = []
        qdrant_total_times = []
        faiss_search_times = []
        faiss_metadata_times = []
        qdrant_search_times = []
        
        for i in range(5):
            print(f"  Run {i+1}/5...", end=" ")
            # Generate different query each time
            test_query = np.random.rand(1024).tolist()
            
            # FAISS timing
            _, f_timing = vector_db.search_with_timing(test_query, top_k=5)
            faiss_total_times.append(f_timing.get('total_time', 0))
            faiss_search_times.append(f_timing.get('faiss_index_search', 0))
            faiss_metadata_times.append(f_timing.get('qdrant_metadata_retrieval', 0))
            
            # Qdrant timing
            _, q_timing = vector_db.search_qdrant_only_with_timing(test_query, top_k=5)
            qdrant_total_times.append(q_timing.get('total_time', 0))
            qdrant_search_times.append(q_timing.get('qdrant_search_with_metadata', 0))
            print("✓")
        
        # Calculate averages
        avg_faiss_total = np.mean(faiss_total_times)
        avg_qdrant_total = np.mean(qdrant_total_times)
        avg_faiss_search = np.mean(faiss_search_times)
        avg_faiss_metadata = np.mean(faiss_metadata_times)
        avg_qdrant_search = np.mean(qdrant_search_times)
        avg_speedup = avg_qdrant_total / avg_faiss_total if avg_faiss_total > 0 else float('inf')
        
        print(f"\n📈 Average Performance Results ({len(faiss_total_times)} runs):")
        print("-" * 60)
        print(f"FAISS + Qdrant total:         {avg_faiss_total:.6f} ± {np.std(faiss_total_times):.6f}s")
        print(f"  - FAISS search only:        {avg_faiss_search:.6f} ± {np.std(faiss_search_times):.6f}s")
        print(f"  - Metadata retrieval:       {avg_faiss_metadata:.6f} ± {np.std(faiss_metadata_times):.6f}s")
        print(f"Qdrant-only total:            {avg_qdrant_total:.6f} ± {np.std(qdrant_total_times):.6f}s")
        print(f"Average performance ratio:    {avg_speedup:.2f}x")
        print()
        
        # Performance insights
        if avg_speedup > 1.2:
            print(f"💡 FAISS is {avg_speedup:.1f}x faster on average")
            print(f"   Pure FAISS search: {avg_faiss_search:.6f}s vs Qdrant: {avg_qdrant_search:.6f}s")
        elif avg_speedup < 0.8:
            print(f"💡 Qdrant is {1/avg_speedup:.1f}x faster on average")
        else:
            print("💡 Both methods have similar performance")
        
        if avg_faiss_metadata > avg_faiss_search:
            print(f"💡 Metadata retrieval ({avg_faiss_metadata:.6f}s) is the bottleneck in FAISS method")
        else:
            print(f"💡 FAISS search ({avg_faiss_search:.6f}s) is faster than metadata retrieval")
        
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


def index_rebuild():
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

def get_top_k_input():
    """Get the number of top results from user"""
    while True:
        try:
            top_k = int(input("Enter number of top results to return (default 5): ") or "5")
            if top_k > 0:
                return top_k
            else:
                print("Please enter a positive number.")
        except ValueError:
            print("Please enter a valid number.")


def text_based_search():
    """Text-based search interface where users can enter manual prompts"""
    
    print("\n=== Text-Based Fish Search CLI ===")
    
    try:
        # Get top_k from user at the start
        top_k = get_top_k_input()
        
        # Initialize Qwen text embedder
        print(f"\n🤖 Initializing Qwen text embedding model...")
        
        text_embedder = None
        try:
            text_embedder = QwenEmbedder()
            print("✅ Qwen text embedder initialized successfully!")
            
        except Exception as e:
            print(f"❌ Failed to initialize Qwen embedder: {e}")
            print("💡 Will use random vectors as fallback")
            text_embedder = None
        except KeyboardInterrupt:
            print("🛑 Model loading interrupted by user")
            print("💡 Will use random vectors as fallback")
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
                search_and_display_results_with_embed_timing(vector_db, query_vector, top_k, "Random Vector", 0.0)
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
                        import time
                        embed_start = time.time()
                        query_vector = text_embedder.encode_fish_query(user_input)
                        embed_time = time.time() - embed_start
                        print(f"✅ Text successfully converted to embedding! (took {embed_time:.6f} seconds)")
                        search_and_display_results_with_embed_timing(vector_db, query_vector, top_k, user_input, embed_time)
                    except Exception as e:
                        print(f"❌ Error during text embedding: {e}")
                        print("🎲 Falling back to random vector...")
                        query_vector = np.random.rand(1024).tolist()
                        search_and_display_results_with_embed_timing(vector_db, query_vector, top_k, f"{user_input} (random fallback)", 0.0)
                else:
                    print("⚠️  Text embedder not available, using random vector...")
                    query_vector = np.random.rand(1024).tolist()
                    search_and_display_results_with_embed_timing(vector_db, query_vector, top_k, f"{user_input} (random)", 0.0)
        
    except KeyboardInterrupt:
        print("\n👋 Search interrupted. Goodbye!")
    except Exception as e:
        print(f"❌ Error during text search: {e}")


def search_and_display_results(vector_db, query_vector, top_k, query_description):
    """Helper function to search and display results with detailed timing"""
    try:
        print(f"⏳ Searching...")
        
        # Use the new timing-enabled search
        results, timing_info = vector_db.search_with_timing(query_vector, top_k=top_k)
        
        if not results:
            print("❌ No results found.")
            display_timing_info(timing_info, "FAISS + Qdrant")
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
        
        # Display detailed timing information
        display_timing_info(timing_info, "FAISS + Qdrant")
        
    except Exception as e:
        print(f"❌ Error during search: {e}")


def search_and_display_results_with_embed_timing(vector_db, query_vector, top_k, query_description, embed_time):
    """Helper function to search and display results with detailed timing including text embedding"""
    try:
        print(f"⏳ Searching...")
        
        # Use the new timing-enabled search
        results, timing_info = vector_db.search_with_timing(query_vector, top_k=top_k)
        
        if not results:
            print("❌ No results found.")
            display_timing_info_with_embedding(timing_info, "FAISS + Qdrant", embed_time)
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
        
        # Display detailed timing information including embedding
        display_timing_info_with_embedding(timing_info, "FAISS + Qdrant", embed_time)
        
    except Exception as e:
        print(f"❌ Error during search: {e}")


def display_timing_info(timing_info, method_name):
    """Display detailed timing information in a formatted way"""
    print(f"\n⏱️  {method_name} Timing Breakdown:")
    print("=" * 60)
    
    if 'error' in timing_info:
        print(f"❌ Error: {timing_info['error']}")
        print(f"Total time: {timing_info.get('total_time', 0):.6f} seconds")
        return
    
    # Display timing breakdown
    if method_name == "FAISS + Qdrant":
        # FAISS method timing breakdown
        print(f"1. Vector normalization:      {timing_info.get('vector_normalization', 0):.6f} seconds")
        print(f"2. FAISS index search:        {timing_info.get('faiss_index_search', 0):.6f} seconds")
        print(f"3. ID mapping & preparation:  {timing_info.get('id_mapping_preparation', 0):.6f} seconds")
        print(f"4. Qdrant metadata retrieval: {timing_info.get('qdrant_metadata_retrieval', 0):.6f} seconds")
        print(f"5. Result processing:         {timing_info.get('result_processing', 0):.6f} seconds")
        print("-" * 60)
        print(f"📊 TOTAL TIME:                {timing_info.get('total_time', 0):.6f} seconds")
        print(f"📈 Results found:             {timing_info.get('results_count', 0)}")
        print(f"🔍 FAISS vectors searched:    {timing_info.get('faiss_vectors_searched', 0):,}")
        print(f"🎯 Qdrant IDs found:          {timing_info.get('qdrant_ids_found', 0)}")
        
        # Performance insights
        faiss_time = timing_info.get('faiss_index_search', 0)
        qdrant_time = timing_info.get('qdrant_metadata_retrieval', 0)
        total_time = timing_info.get('total_time', 0)
        
        if total_time > 0:
            faiss_percent = (faiss_time / total_time) * 100
            qdrant_percent = (qdrant_time / total_time) * 100
            print(f"💡 FAISS search: {faiss_percent:.1f}% of total time")
            print(f"💡 Qdrant retrieval: {qdrant_percent:.1f}% of total time")
    
    elif method_name == "Qdrant Only":
        # Qdrant-only method timing breakdown
        print(f"1. Qdrant search + metadata:  {timing_info.get('qdrant_search_with_metadata', 0):.6f} seconds")
        print(f"2. Result processing:         {timing_info.get('result_processing', 0):.6f} seconds")
        print("-" * 60)
        print(f"📊 TOTAL TIME:                {timing_info.get('total_time', 0):.6f} seconds")
        print(f"📈 Results found:             {timing_info.get('results_count', 0)}")
    
    print("=" * 60)


def display_timing_info_with_embedding(timing_info, method_name, embed_time):
    """Display detailed timing information including text embedding time"""
    print(f"\n⏱️  Complete Pipeline Timing Breakdown:")
    print("=" * 70)
    
    if 'error' in timing_info:
        print(f"❌ Error: {timing_info['error']}")
        if embed_time > 0:
            print(f"Text embedding time: {embed_time:.6f} seconds")
        print(f"Total time: {timing_info.get('total_time', 0):.6f} seconds")
        return
    
    # Show complete pipeline including text embedding
    total_pipeline_time = embed_time + timing_info.get('total_time', 0)
    
    if embed_time > 0:
        print(f"0. Text → Vector (Qwen):      {embed_time:.6f} seconds")
    else:
        print(f"0. Vector generation:         0.000000 seconds (random/provided)")
        
    print(f"1. Vector normalization:      {timing_info.get('vector_normalization', 0):.6f} seconds")
    print(f"2. FAISS index search:        {timing_info.get('faiss_index_search', 0):.6f} seconds")
    print(f"3. ID mapping & preparation:  {timing_info.get('id_mapping_preparation', 0):.6f} seconds")
    print(f"4. Qdrant metadata retrieval: {timing_info.get('qdrant_metadata_retrieval', 0):.6f} seconds")
    print(f"5. Result processing:         {timing_info.get('result_processing', 0):.6f} seconds")
    print("-" * 70)
    print(f"📊 VECTOR SEARCH SUBTOTAL:    {timing_info.get('total_time', 0):.6f} seconds")
    print(f"🔥 COMPLETE PIPELINE TOTAL:   {total_pipeline_time:.6f} seconds")
    print(f"📈 Results found:             {timing_info.get('results_count', 0)}")
    print(f"🔍 FAISS vectors searched:    {timing_info.get('faiss_vectors_searched', 0):,}")
    print(f"🎯 Qdrant IDs found:          {timing_info.get('qdrant_ids_found', 0)}")
    
    # Performance breakdown percentages
    if total_pipeline_time > 0:
        if embed_time > 0:
            embed_percent = (embed_time / total_pipeline_time) * 100
            print(f"💡 Text embedding: {embed_percent:.1f}% of total pipeline time")
        
        search_time = timing_info.get('faiss_index_search', 0)
        retrieval_time = timing_info.get('qdrant_metadata_retrieval', 0)
        search_percent = (search_time / total_pipeline_time) * 100
        retrieval_percent = (retrieval_time / total_pipeline_time) * 100
        
        print(f"💡 FAISS search: {search_percent:.1f}% of total pipeline time")
        print(f"💡 Qdrant retrieval: {retrieval_percent:.1f}% of total pipeline time")
        
        if embed_time > timing_info.get('total_time', 0):
            print(f"⚠️  Text embedding is the bottleneck ({embed_time:.6f}s)")
        elif retrieval_time > search_time:
            print(f"⚠️  Metadata retrieval is the bottleneck ({retrieval_time:.6f}s)")
        else:
            print(f"✅ Vector search is optimized")
    
    print("=" * 70)


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
    print("2. 🔄 Index rebuild")
    print("3. ❌ Exit")
    
    try:
        choice = input("\nEnter your choice (1-3): ").strip()
        
        if choice == "1":
            text_based_search()
        elif choice == "2":
            index_rebuild()
        elif choice == "3":
            print("👋 Goodbye!")
        else:
            print("❌ Invalid choice. Please run again and select 1-3.")
    
    except KeyboardInterrupt:
        print("\n👋 Goodbye!")


if __name__ == "__main__":
    main() 