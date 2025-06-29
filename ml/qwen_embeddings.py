"""
Qwen text embedding utilities for fish search
"""

from typing import List, Optional
import torch
import numpy as np
import platform
import os
import warnings

# FIX: Set OBJC_DISABLE_INITIALIZE_FORK_SAFETY to prevent segfaults on macOS
# This is a common workaround for PyTorch multiprocessing issues on macOS
if platform.system() == "Darwin":
    os.environ["OBJC_DISABLE_INITIALIZE_FORK_SAFETY"] = "YES"

# Suppress warnings to reduce noise during model loading
warnings.filterwarnings("ignore", category=FutureWarning)
warnings.filterwarnings("ignore", category=UserWarning)

try:
    from sentence_transformers import SentenceTransformer
    SENTENCE_TRANSFORMERS_AVAILABLE = True
except ImportError:
    print("⚠️  sentence-transformers not available. Installing...")
    os.system("pip install sentence-transformers")
    try:
        from sentence_transformers import SentenceTransformer
        SENTENCE_TRANSFORMERS_AVAILABLE = True
    except ImportError:
        SENTENCE_TRANSFORMERS_AVAILABLE = False


class QwenEmbedder:
    """Qwen text embedder for fish descriptions"""
    
    def __init__(self, device: Optional[str] = None):
        """
        Initialize the Qwen text embedder
        
        Args:
            device: Device to run the model on ('cuda', 'cpu', or None for auto-detect)
        """
        self.device = device
        self.model = None
        self.model_name = "Qwen/Qwen3-Embedding-0.6B"
        self.embedding_dimension = None
        
        # Load Qwen model
        self._load_qwen_model()
    
    def _load_qwen_model(self):
        """Load Qwen model"""
        
        if not SENTENCE_TRANSFORMERS_AVAILABLE:
            raise ImportError("sentence-transformers is required for Qwen model")
        
        # Determine device
        if not self.device:
            self.device = self._get_device()
        
        print(f"🤖 Initializing Qwen text embedding model...")
        print(f"📱 Using device: {self.device}")
        
        # Set environment variables for stability
        os.environ["TOKENIZERS_PARALLELISM"] = "false"
        
        try:
            print(f"\n🔄 Loading {self.model_name}...")
            
            self.model = SentenceTransformer(
                self.model_name,
                device=self.device,
                use_auth_token=False
            )
            
            # Test the model with a simple encoding
            test_embedding = self.model.encode(
                "test", 
                convert_to_tensor=False,
                show_progress_bar=False
            )
            
            # Determine embedding dimension
            if hasattr(test_embedding, 'shape'):
                self.embedding_dimension = test_embedding.shape[-1]
            elif isinstance(test_embedding, (list, tuple)):
                self.embedding_dimension = len(test_embedding)
            else:
                self.embedding_dimension = 1024  # Qwen default
            
            print(f"✅ Successfully loaded {self.model_name}!")
            print(f"📏 Embedding dimension: {self.embedding_dimension}")
            
        except Exception as e:
            print(f"❌ Failed to load {self.model_name}: {e}")
            raise RuntimeError(f"Could not load Qwen model: {e}")
    
    def _get_device(self):
        """Get device configuration"""
        if torch.cuda.is_available():
            return "cuda"
        elif hasattr(torch.backends, "mps") and torch.backends.mps.is_available():
            return "mps"
        else:
            return "cpu"
    
    def encode_text(self, text: str) -> List[float]:
        """
        Convert text to embedding vector
        
        Args:
            text: Input text to embed
            
        Returns:
            List of float values representing the text embedding
        """
        if self.model is None:
            raise RuntimeError("Model not loaded")
        
        embedding = self.model.encode(
            text,
            convert_to_tensor=False,
            normalize_embeddings=True,
            show_progress_bar=False
        )
        
        # Convert to list
        if hasattr(embedding, 'tolist'):
            return embedding.tolist()
        else:
            return list(embedding)
    
    def encode_texts(self, texts: List[str], batch_size: int = 16) -> List[List[float]]:
        """
        Convert multiple texts to embedding vectors
        
        Args:
            texts: List of input texts to embed
            batch_size: Number of texts to process at once
            
        Returns:
            List of embedding vectors
        """
        if self.model is None:
            raise RuntimeError("Model not loaded")
        
        embeddings = self.model.encode(
            texts,
            batch_size=batch_size,
            convert_to_tensor=False,
            normalize_embeddings=True,
            show_progress_bar=False
        )
        
        # Convert to list of lists
        if hasattr(embeddings, 'tolist'):
            return embeddings.tolist()
        else:
            return [list(emb) for emb in embeddings]
    
    def preprocess_fish_query(self, query: str) -> str:
        """
        Preprocess fish-related search queries for better embedding quality
        
        Args:
            query: Raw user query
            
        Returns:
            Preprocessed query optimized for fish search
        """
        # Convert to lowercase for consistency
        query = query.lower().strip()
        
        # If query doesn't contain fish-related terms, add context
        fish_terms = ["fish", "shark", "ray", "eel", "marine", "aquatic", "species", "animal"]
        has_fish_context = any(term in query for term in fish_terms)
        
        if not has_fish_context and len(query.split()) <= 5:
            # Add fish context for short, generic queries
            query = f"fish species with {query} characteristics"
        
        # Add instruction for better embedding
        query = f"Find fish species: {query}"
        
        return query
    
    def encode_fish_query(self, query: str, add_context: bool = False, target_dimension: int = 1024) -> List[float]:
        """
        Encode a fish-related search query with dimension adjustment
        
        Args:
            query: Fish search query
            add_context: Whether to add fish-specific context
            target_dimension: Target dimension for fish embeddings (default 1024)
            
        Returns:
            Embedding vector adjusted to target dimension
        """
        # Preprocess query if requested
        if add_context:
            processed_query = self.preprocess_fish_query(query)
        else:
            processed_query = query
        
        # Get embedding
        embedding = self.encode_text(processed_query)
        
        # Adjust dimension to match fish embeddings (1024)
        if len(embedding) != target_dimension:
            embedding = self._adjust_embedding_dimension(embedding, target_dimension)
        
        return embedding
    
    def _adjust_embedding_dimension(self, embedding: List[float], target_dimension: int) -> List[float]:
        """
        Adjust embedding dimension to match target dimension
        
        Args:
            embedding: Original embedding vector
            target_dimension: Desired output dimension
            
        Returns:
            Adjusted embedding vector
        """
        current_dimension = len(embedding)
        
        if current_dimension == target_dimension:
            return embedding
        elif current_dimension < target_dimension:
            # Pad with interpolated values
            padding_size = target_dimension - current_dimension
            
            # Use statistics of existing values for intelligent padding
            embedding_array = np.array(embedding)
            mean_value = np.mean(embedding_array)
            std_value = np.std(embedding_array)
            
            # Create padding with similar distribution
            np.random.seed(42)  # For reproducible results
            padding = np.random.normal(mean_value, std_value * 0.1, padding_size)
            
            return embedding + padding.tolist()
        else:
            # Reduce dimensions using systematic sampling
            step = current_dimension / target_dimension
            indices = [int(i * step) for i in range(target_dimension)]
            return [embedding[i] for i in indices]
    
    def get_model_info(self) -> dict:
        """Get information about the loaded model"""
        return {
            "model_name": self.model_name,
            "embedding_dimension": self.embedding_dimension or 0,
            "device": self.device or "unknown",
            "is_loaded": self.model is not None,
            "model_type": "Qwen Embedder"
        }


def test_qwen_embedder():
    """Test the Qwen embedder functionality"""
    print("=== Testing Qwen Text Embedder ===")
    
    try:
        # Initialize embedder
        print("🚀 Initializing Qwen embedder...")
        embedder = QwenEmbedder()
        
        # Show model info
        info = embedder.get_model_info()
        print(f"\n📋 Model Info:")
        for key, value in info.items():
            print(f"   {key}: {value}")
        
        # Test queries
        test_queries = [
            "large predatory fish with sharp teeth",
            "small colorful tropical fish", 
            "elongated eel-like fish",
            "spotted shark",
            "blue fish"
        ]
        
        print(f"\n🧪 Testing {len(test_queries)} queries:")
        for i, query in enumerate(test_queries):
            print(f"\n{i+1}. Query: '{query}'")
            
            # Get embedding
            embedding = embedder.encode_fish_query(query)
            print(f"   ✅ Embedding dimension: {len(embedding)}")
            print(f"   📊 First 5 values: {[round(x, 4) for x in embedding[:5]]}")
            
            # Show preprocessing
            processed = embedder.preprocess_fish_query(query)
            if processed != query.lower():
                print(f"   🔄 Preprocessed: '{processed}'")
        
        print("\n✅ Qwen embedder test completed!")
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    test_qwen_embedder() 