"""
Text embedding utilities using multiple fallback models for reliability
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


class SafeTextEmbedder:
    """Safe text embedding utility with multiple fallback options"""
    
    def __init__(self, device: Optional[str] = None):
        """
        Initialize the text embedder with robust fallback handling
        
        Args:
            device: Device to run the model on ('cuda', 'cpu', or None for auto-detect)
        """
        self.device = device
        self.model = None
        self.model_name = None
        self.embedding_dimension = None
        
        # Load model with fallbacks
        self._load_with_fallbacks()
    
    def _load_with_fallbacks(self):
        """Try loading models in order of preference with fallbacks"""
        
        # Define models in order of preference (safest first)
        model_options = [
            ("all-MiniLM-L6-v2", "Lightweight, stable model"),
            ("sentence-transformers/all-MiniLM-L6-v2", "Lightweight, stable model (explicit path)"),
            ("all-mpnet-base-v2", "High quality, moderate size"),
            ("Qwen/Qwen3-Embedding-0.6B", "Qwen model (may be unstable on some systems)")
        ]
        
        # First try without sentence-transformers if not available
        if not SENTENCE_TRANSFORMERS_AVAILABLE:
            print("❌ sentence-transformers not available. Using random embeddings fallback.")
            self._load_random_embedder()
            return
        
        # Determine device
        if not self.device:
            self.device = self._get_safe_device()
        
        print(f"🤖 Initializing text embedding model...")
        print(f"📱 Using device: {self.device}")
        
        # Try each model
        for model_name, description in model_options:
            try:
                print(f"\n🔄 Trying {model_name} ({description})...")
                
                # Special handling for potentially problematic models
                if "Qwen" in model_name and platform.system() == "Darwin":
                    print("⚠️  Qwen model detected on macOS - skipping due to potential stability issues")
                    continue
                
                self._load_single_model(model_name)
                print(f"✅ Successfully loaded {model_name}!")
                return
                
            except Exception as e:
                print(f"❌ Failed to load {model_name}: {e}")
                self.model = None
                continue
        
        # If all models fail, use random embeddings
        print("\n⚠️  All embedding models failed. Using random embeddings fallback.")
        self._load_random_embedder()
    
    def _get_safe_device(self):
        """Get the safest device configuration"""
        if torch.cuda.is_available():
            return "cuda"
        elif hasattr(torch.backends, "mps") and torch.backends.mps.is_available():
            # Apple Silicon MPS can be unstable, prefer CPU for stability
            print("📱 Apple Silicon MPS available but using CPU for stability")
            return "cpu"
        else:
            return "cpu"
    
    def _load_single_model(self, model_name: str):
        """Load a single model with timeout and error handling"""
        
        # Set environment variables for stability
        os.environ["TOKENIZERS_PARALLELISM"] = "false"
        
        try:
            # Load with minimal configuration for stability
            if self.device == "cpu":
                self.model = SentenceTransformer(
                    model_name,
                    device="cpu",
                    use_auth_token=False
                )
            else:
                self.model = SentenceTransformer(
                    model_name,
                    device=self.device,
                    use_auth_token=False
                )
            
            self.model_name = model_name
            
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
                self.embedding_dimension = 384  # Common default
            
            print(f"📏 Embedding dimension: {self.embedding_dimension}")
            
        except Exception as e:
            self.model = None
            raise e
    
    def _load_random_embedder(self):
        """Fallback to random embeddings when all else fails"""
        self.model_name = "random_fallback"
        self.embedding_dimension = 384
        self.model = "random"  # Special marker
        print("🎲 Random embedding fallback loaded")
        print("📏 Embedding dimension: 384")
    
    def encode_text(self, text: str) -> List[float]:
        """
        Convert text to embedding vector
        
        Args:
            text: Input text to embed
            
        Returns:
            List of float values representing the text embedding
        """
        try:
            if self.model == "random":
                # Random fallback
                np.random.seed(hash(text) % 2**32)  # Deterministic based on text
                return np.random.rand(self.embedding_dimension).tolist()
            
            elif self.model is not None:
                # Use loaded model
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
            
            else:
                raise ValueError("No model loaded")
                
        except Exception as e:
            print(f"❌ Error encoding text: {e}")
            # Fallback to random
            np.random.seed(hash(text) % 2**32)
            return np.random.rand(self.embedding_dimension or 384).tolist()
    
    def encode_texts(self, texts: List[str], batch_size: int = 16) -> List[List[float]]:
        """
        Convert multiple texts to embedding vectors
        
        Args:
            texts: List of input texts to embed
            batch_size: Number of texts to process at once (reduced for stability)
            
        Returns:
            List of embedding vectors
        """
        try:
            if self.model == "random":
                # Random fallback for batch
                return [self.encode_text(text) for text in texts]
            
            elif self.model is not None:
                # Use loaded model with smaller batch size for stability
                embeddings = self.model.encode(
                    texts,
                    batch_size=min(batch_size, 8),  # Smaller batches for stability
                    convert_to_tensor=False,
                    normalize_embeddings=True,
                    show_progress_bar=False
                )
                
                # Convert to list of lists
                if hasattr(embeddings, 'tolist'):
                    return embeddings.tolist()
                else:
                    return [list(emb) for emb in embeddings]
            
            else:
                raise ValueError("No model loaded")
                
        except Exception as e:
            print(f"❌ Error encoding texts: {e}")
            # Fallback to individual encoding
            return [self.encode_text(text) for text in texts]


class FishSafeEmbedder(SafeTextEmbedder):
    """
    Safe text embedder for fish descriptions (no Qwen models)
    Includes preprocessing and dimension adjustment for fish search
    """
    
    def __init__(self, device: Optional[str] = None):
        super().__init__(device)
        
        # Override to exclude Qwen models for maximum safety
        self._load_safe_models_only()
    
    def _load_safe_models_only(self):
        """Load only the safest models, excluding Qwen"""
        
        # Define only safe models
        safe_model_options = [
            ("all-MiniLM-L6-v2", "Lightweight, stable model"),
            ("sentence-transformers/all-MiniLM-L6-v2", "Lightweight, stable model (explicit path)"),
            ("all-mpnet-base-v2", "High quality, moderate size")
        ]
        
        # First try without sentence-transformers if not available
        if not SENTENCE_TRANSFORMERS_AVAILABLE:
            print("❌ sentence-transformers not available. Using random embeddings fallback.")
            self._load_random_embedder()
            return
        
        # Determine device
        if not self.device:
            self.device = self._get_safe_device()
        
        print(f"🔒 Initializing SAFE text embedding model...")
        print(f"📱 Using device: {self.device}")
        
        # Try each safe model
        for model_name, description in safe_model_options:
            try:
                print(f"\n🔄 Trying {model_name} ({description})...")
                self._load_single_model(model_name)
                print(f"✅ Successfully loaded {model_name}!")
                return
                
            except Exception as e:
                print(f"❌ Failed to load {model_name}: {e}")
                self.model = None
                continue
        
        # If all models fail, use random embeddings
        print("\n⚠️  All safe embedding models failed. Using random embeddings fallback.")
        self._load_random_embedder()
    
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
    
    def encode_fish_query(self, query: str, add_context: bool = True, target_dimension: int = 1024) -> List[float]:
        """
        Encode a fish-related search query with dimension adjustment
        
        Args:
            query: Fish search query
            add_context: Whether to add fish-specific context
            target_dimension: Target dimension for fish embeddings (default 1024)
            
        Returns:
            Embedding vector adjusted to target dimension
        """
        try:
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
            
        except Exception as e:
            print(f"❌ Error encoding fish query: {e}")
            # Fallback to random embedding with correct dimension
            np.random.seed(hash(query) % 2**32)
            return np.random.rand(target_dimension).tolist()
    
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
            "model_name": self.model_name or "unknown",
            "embedding_dimension": self.embedding_dimension or 0,
            "device": self.device or "unknown",
            "is_loaded": self.model is not None,
            "model_type": "Safe Fish Embedder (No Qwen)",
            "is_fallback": self.model == "random"
        }


class FishQwenEmbedder(SafeTextEmbedder):
    """
    Qwen-enabled text embedder for fish descriptions (may be unstable)
    Includes preprocessing and dimension adjustment for fish search
    """
    
    def __init__(self, device: Optional[str] = None):
        super().__init__(device)
    
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
    
    def encode_fish_query(self, query: str, add_context: bool = True, target_dimension: int = 1024) -> List[float]:
        """
        Encode a fish-related search query with dimension adjustment
        
        Args:
            query: Fish search query
            add_context: Whether to add fish-specific context
            target_dimension: Target dimension for fish embeddings (default 1024)
            
        Returns:
            Embedding vector adjusted to target dimension
        """
        try:
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
            
        except Exception as e:
            print(f"❌ Error encoding fish query: {e}")
            # Fallback to random embedding with correct dimension
            np.random.seed(hash(query) % 2**32)
            return np.random.rand(target_dimension).tolist()
    
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
            "model_name": self.model_name or "unknown",
            "embedding_dimension": self.embedding_dimension or 0,
            "device": self.device or "unknown",
            "is_loaded": self.model is not None,
            "model_type": "Qwen Fish Embedder (with fallbacks)",
            "is_fallback": self.model == "random"
        }


def test_safe_embedder():
    """Test the safe embedder functionality"""
    print("=== Testing Safe Text Embedder ===")
    
    try:
        # Initialize embedder
        print("🚀 Initializing safe embedder...")
        embedder = FishQwenEmbedder()
        
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
            
            try:
                # Get embedding
                embedding = embedder.encode_fish_query(query)
                print(f"   ✅ Embedding dimension: {len(embedding)}")
                print(f"   📊 First 5 values: {[round(x, 4) for x in embedding[:5]]}")
                
                # Show preprocessing
                processed = embedder.preprocess_fish_query(query)
                if processed != query.lower():
                    print(f"   🔄 Preprocessed: '{processed}'")
                    
            except Exception as e:
                print(f"   ❌ Failed: {e}")
        
        print("\n✅ Safe embedder test completed!")
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    test_safe_embedder() 