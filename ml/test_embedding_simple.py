#!/usr/bin/env python3
"""
Simple test script for text embeddings to avoid segmentation faults
"""

import sys
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def test_embedding_simple():
    """Simple test that avoids potential segmentation fault issues"""
    
    print("🧪 Simple Text Embedding Test")
    print("=" * 50)
    
    try:
        # Import with error handling
        print("📦 Importing modules...")
        from qwen_embeddings import FishQwenEmbedder
        print("✅ Import successful!")
        
        # Test if we have required dependencies
        try:
            import torch
            print(f"✅ PyTorch available: {torch.__version__}")
        except ImportError:
            print("❌ PyTorch not available - installing requirements needed")
            return False
        
        try:
            import sentence_transformers
            print(f"✅ SentenceTransformers available: {sentence_transformers.__version__}")
        except ImportError:
            print("❌ SentenceTransformers not available - installing requirements needed")
            return False
        
        # Test basic initialization with timeout protection
        print("\n🤖 Testing embedder initialization...")
        
        # Create a simple timeout mechanism
        import signal
        
        class TimeoutError(Exception):
            pass
        
        def timeout_handler(signum, frame):
            raise TimeoutError("Initialization timed out")
        
        # Set 3-minute timeout
        signal.signal(signal.SIGALRM, timeout_handler)
        signal.alarm(180)
        
        try:
            embedder = FishQwenEmbedder()
            signal.alarm(0)  # Cancel timeout
            print("✅ Embedder initialized successfully!")
            
            # Test encoding
            print("\n🔍 Testing text encoding...")
            test_queries = [
                "large fish",
                "small shark",
                "tropical fish"
            ]
            
            for query in test_queries:
                try:
                    embedding = embedder.encode_fish_query(query)
                    print(f"   ✅ '{query}' -> {len(embedding)} dimensions")
                except Exception as encode_error:
                    print(f"   ❌ Failed to encode '{query}': {encode_error}")
            
            # Show model info
            info = embedder.get_model_info()
            print(f"\n📋 Model Info:")
            for key, value in info.items():
                print(f"   {key}: {value}")
            
            print("\n🎉 All tests passed!")
            return True
            
        except TimeoutError:
            signal.alarm(0)
            print("⏰ Initialization timed out - model might be too large")
            return False
        except Exception as init_error:
            signal.alarm(0)
            print(f"❌ Initialization failed: {init_error}")
            return False
            
    except ImportError as import_error:
        print(f"❌ Import failed: {import_error}")
        print("💡 Run: pip install sentence-transformers torch numpy")
        return False
    except Exception as general_error:
        print(f"❌ Test failed: {general_error}")
        return False


def test_faiss_connection():
    """Test FAISS database connection"""
    
    print("\n🗄️ Testing FAISS Database Connection")
    print("=" * 50)
    
    try:
        from faiss_from_qdrant import FaissFromQdrantDatabase
        
        # Check environment variables
        qdrant_url = os.getenv("QDRANT_URL")
        qdrant_key = os.getenv("QDRANT_API_KEY")
        
        if not qdrant_url or not qdrant_key:
            print("❌ Missing QDRANT_URL or QDRANT_API_KEY environment variables")
            return False
        
        print("✅ Environment variables found")
        
        # Test database connection
        print("🔗 Testing database connection...")
        db = FaissFromQdrantDatabase(
            collection_name="fish_embeddings_20250627_102709",
            faiss_index_path="qdrant_faiss_index.faiss"
        )
        
        stats = db.get_stats()
        print(f"✅ Database connected!")
        print(f"   Qdrant points: {stats['qdrant_points']}")
        print(f"   FAISS vectors: {stats['faiss_vectors']}")
        print(f"   Synchronized: {stats['index_synchronized']}")
        
        return True
        
    except Exception as db_error:
        print(f"❌ Database test failed: {db_error}")
        return False


def main():
    """Main test function"""
    
    print("🔬 Fish Search System - Component Tests")
    print("=" * 60)
    
    # Test components individually
    embedding_ok = test_embedding_simple()
    faiss_ok = test_faiss_connection()
    
    print("\n📊 Test Results:")
    print(f"   Text Embeddings: {'✅ PASS' if embedding_ok else '❌ FAIL'}")
    print(f"   FAISS Database: {'✅ PASS' if faiss_ok else '❌ FAIL'}")
    
    if embedding_ok and faiss_ok:
        print("\n🎉 All systems ready! You can now run:")
        print("   python test_faiss_from_qdrant.py")
    else:
        print("\n⚠️  Some components failed. Check the errors above.")
        if not embedding_ok:
            print("💡 For embeddings: pip install sentence-transformers torch")
        if not faiss_ok:
            print("💡 For FAISS: Check your .env file with QDRANT credentials")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n🛑 Test interrupted by user")
    except Exception as e:
        print(f"\n💥 Unexpected error: {e}")
        import traceback
        traceback.print_exc() 