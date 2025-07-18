from fastapi import FastAPI, HTTPException, UploadFile, File, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import uvicorn
import numpy as np
import time
import os
from dotenv import load_dotenv
from PIL import Image
import io

# Import our fish search components
from faiss_from_qdrant import FaissFromQdrantDatabase
from qwen_embeddings import QwenEmbedder
from fish_species import FishSpecies

# Import picture verification components
from pic_verification.embedder import Embedder

# Load environment variables from .env file
load_dotenv()

app = FastAPI(title="FishMasters ML API", version="2.0.0", description="Fish search and identification API")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variables for initialization
vector_db: Optional[FaissFromQdrantDatabase] = None
image_vector_db: Optional[FaissFromQdrantDatabase] = None
qwen_embedder: Optional[QwenEmbedder] = None
image_embedder: Optional[Embedder] = None
initialization_mode: str = "none"  # "none", "low_resources", "high_resources", "low_res_pic", "random_pic"


class FishSearchRequest(BaseModel):
    description: str = Field(..., description="Text description of the fish to search for")
    top_k: int = Field(default=5, ge=1, le=50, description="Number of top results to return")
    mode: str = Field(default="auto", description="Search mode: 'low_resources', 'high_resources', or 'auto'")


class FishResult(BaseModel):
    id: int
    name: str
    similarity_score: float
    genus: Optional[str] = None
    species: Optional[str] = None
    fbname: Optional[str] = None
    description: Optional[str] = None


class FishSearchResponse(BaseModel):
    success: bool
    results: List[FishResult]
    query: str
    mode_used: str
    timing: Dict[str, float]
    total_time: float


class InitializationRequest(BaseModel):
    mode: str = Field(..., description="Initialization mode: 'low_resources' or 'high_resources'")


class StatusResponse(BaseModel):
    status: str
    initialized: bool
    mode: str
    text_database_loaded: bool
    image_database_loaded: bool
    qwen_loaded: bool
    image_embedder_loaded: bool
    fish_count: int
    message: str


class ImageSearchResponse(BaseModel):
    success: bool
    results: List[FishResult]
    mode_used: str
    timing: Dict[str, float]
    total_time: float


def initialize_database():
    """Initialize the FAISS vector database for text embeddings"""
    global vector_db
    
    try:
        if vector_db is None:
            print("🗄️ Initializing FAISS database for text embeddings...")
            vector_db = FaissFromQdrantDatabase(
                collection_name="fish_embeddings_20250627_102709",
                faiss_index_path="qdrant_faiss_index.faiss"
            )
            print("✅ Text database initialized successfully")
        return True
    except Exception as e:
        print(f"❌ Failed to initialize text database: {e}")
        return False


def initialize_image_database():
    """Initialize the FAISS vector database for image embeddings"""
    global image_vector_db
    
    try:
        if image_vector_db is None:
            print("🖼️ Initializing FAISS database for image embeddings...")
            image_vector_db = FaissFromQdrantDatabase(
                collection_name="fish_image_embeddings",
                faiss_index_path="fish_image_embeddings_faiss_index.faiss",  # Separate index for images
                embedding_dimension=512  # ResNet18 produces 512D embeddings
            )
            print("✅ Image database initialized successfully")
        return True
    except Exception as e:
        print(f"❌ Failed to initialize image database: {e}")
        return False


def initialize_qwen_embedder():
    """Initialize the Qwen text embedder"""
    global qwen_embedder
    
    try:
        if qwen_embedder is None:
            print("🤖 Initializing Qwen text embedding model...")
            qwen_embedder = QwenEmbedder()
            print("✅ Qwen embedder initialized successfully")
        return True
    except Exception as e:
        print(f"❌ Failed to initialize Qwen embedder: {e}")
        return False


def initialize_image_embedder():
    """Initialize the image embedder for fish image processing"""
    global image_embedder
    
    try:
        if image_embedder is None:
            print("🖼️ Initializing ResNet18 image embedding model...")
            image_embedder = Embedder()
            print("✅ Image embedder initialized successfully")
        return True
    except Exception as e:
        print(f"❌ Failed to initialize image embedder: {e}")
        return False


@app.post("/initialize", response_model=StatusResponse)
async def initialize_system(request: InitializationRequest):
    """
    Initialize the fish search system with specified mode.
    
    - **low_resources**: Only initialize text database, use random vectors for search
    - **low_res_pic**: Initialize text database and image embedder, use random vectors for text search
    - **random_pic**: Initialize image database only, use random vectors for image search (testing)
    - **high_resources**: Initialize all databases and embedders for full functionality
    """
    global initialization_mode
    
    mode = request.mode.lower()
    if mode not in ["low_resources", "low_res_pic", "random_pic", "high_resources"]:
        raise HTTPException(
            status_code=400, 
            detail="Mode must be 'low_resources', 'low_res_pic', 'random_pic', or 'high_resources'"
        )
    
    start_time = time.time()
    
    try:
        # Initialize databases based on mode
        db_success = True
        image_db_success = True
        qwen_success = True
        image_success = True
        
        if mode in ["low_resources", "low_res_pic"]:
            # Initialize text database
            db_success = initialize_database()
            if not db_success:
                raise HTTPException(
                    status_code=500,
                    detail="Failed to initialize text database"
                )
        
        elif mode == "random_pic":
            # Only initialize image database
            image_db_success = initialize_image_database()
            if not image_db_success:
                raise HTTPException(
                    status_code=500,
                    detail="Failed to initialize image database"
                )
        
        elif mode == "high_resources":
            # Initialize both databases
            db_success = initialize_database()
            if not db_success:
                raise HTTPException(
                    status_code=500,
                    detail="Failed to initialize text database"
                )
            
            image_db_success = initialize_image_database()
            if not image_db_success:
                raise HTTPException(
                    status_code=500,
                    detail="Failed to initialize image database"
                )
        
        # Initialize embedders based on mode
        if mode == "high_resources":
            qwen_success = initialize_qwen_embedder()
            if not qwen_success:
                raise HTTPException(
                    status_code=500,
                    detail="Failed to initialize Qwen embeddings model"
                )
            
            image_success = initialize_image_embedder()
            if not image_success:
                raise HTTPException(
                    status_code=500,
                    detail="Failed to initialize image embeddings model"
                )
        
        elif mode == "low_res_pic":
            # Only initialize image embedder, skip Qwen for low resources
            image_success = initialize_image_embedder()
            if not image_success:
                raise HTTPException(
                    status_code=500,
                    detail="Failed to initialize image embeddings model"
                )
        
        initialization_mode = mode
        init_time = time.time() - start_time
        
        # Get database stats
        fish_count = 0
        if vector_db:
            stats = vector_db.get_stats()
            fish_count += stats.get("qdrant_points", 0)
        if image_vector_db:
            image_stats = image_vector_db.get_stats()
            fish_count += image_stats.get("qdrant_points", 0)
        
        return StatusResponse(
            status="success",
            initialized=True,
            mode=mode,
            text_database_loaded=db_success,
            image_database_loaded=image_db_success,
            qwen_loaded=(qwen_embedder is not None),
            image_embedder_loaded=(image_embedder is not None),
            fish_count=fish_count,
            message=f"System initialized in {mode} mode in {init_time:.2f} seconds"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Initialization failed: {str(e)}")


@app.post("/search", response_model=FishSearchResponse)
async def search_fish(request: FishSearchRequest):
    """
    Search for fish based on text description.
    
    The search behavior depends on initialization mode:
    - **low_resources**: Uses random vectors for text search (fast but not semantic)
    - **low_res_pic**: Uses random vectors for text search (image search available)
    - **random_pic**: Not available for text search (image-only mode)
    - **high_resources**: Uses Qwen embeddings for semantic search (slower but accurate)
    - **auto**: Automatically chooses based on what's available
    """
    global vector_db, qwen_embedder, initialization_mode
    
    start_time = time.time()
    timing = {}
    
    # Check if system is initialized
    if vector_db is None:
        # Try to auto-initialize in low resources mode
        if not initialize_database():
            raise HTTPException(
                status_code=503,
                detail="System not initialized. Please call /initialize endpoint first."
            )
        initialization_mode = "low_resources"
    
    # Determine search mode
    requested_mode = request.mode.lower()
    if requested_mode == "auto":
        mode_used = initialization_mode if initialization_mode != "none" else "low_resources"
    elif requested_mode in ["low_resources", "low_res_pic", "high_resources"]:
        mode_used = requested_mode
    elif requested_mode == "random_pic":
        raise HTTPException(
            status_code=400,
            detail="Text search not available in 'random_pic' mode. Use image search instead."
        )
    else:
        raise HTTPException(
            status_code=400,
            detail="Mode must be 'low_resources', 'low_res_pic', 'high_resources', or 'auto'"
        )
    
    # Check if requested mode is available
    if mode_used == "high_resources" and qwen_embedder is None:
        if initialization_mode in ["low_resources", "low_res_pic"]:
            mode_used = initialization_mode
        else:
            raise HTTPException(
                status_code=503,
                detail="High resources mode requested but Qwen embedder not available. Initialize system first or use low_resources/low_res_pic mode."
            )
    
    try:
        # Generate query vector based on mode
        embed_start = time.time()
        
        if mode_used == "high_resources" and qwen_embedder is not None:
            # Use Qwen embeddings for semantic search
            query_vector = qwen_embedder.encode_fish_query(request.description)
            timing["text_embedding"] = time.time() - embed_start
        else:
            # Use random vector for low resources mode
            query_vector = np.random.rand(1024).tolist()
            timing["random_vector_generation"] = time.time() - embed_start
        
        # Perform the search
        search_start = time.time()
        results, search_timing = vector_db.search_with_timing(query_vector, top_k=request.top_k)
        
        # Filter out non-numeric timing values to avoid validation errors
        filtered_timing = {k: v for k, v in search_timing.items() if isinstance(v, (int, float))}
        timing.update(filtered_timing)
        timing["total_search"] = time.time() - search_start
        
        # Convert results to response format
        fish_results = []
        for fish, score in results:
            fish_result = FishResult(
                id=fish.id,
                name=fish.name,
                similarity_score=float(score),
                genus=fish.genus if fish.genus else None,
                species=fish.species if fish.species else None,
                fbname=fish.fbname if fish.fbname else None,
                description=fish.full_description[:200] + "..." if len(fish.full_description) > 200 else fish.full_description
            )
            fish_results.append(fish_result)
        
        total_time = time.time() - start_time
        timing["total_request"] = total_time
        
        return FishSearchResponse(
            success=True,
            results=fish_results,
            query=request.description,
            mode_used=mode_used,
            timing=timing,
            total_time=total_time
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Search failed: {str(e)}"
        )


@app.post("/search_image", response_model=ImageSearchResponse)
async def search_fish_by_image(image: UploadFile = File(...)):
    """
    Search for fish based on uploaded image.
    
    The search uses ResNet18 image embeddings to find similar fish images.
    Supports modes: 'high_resources', 'low_res_pic' (real embeddings), 'random_pic' (random vectors for testing).
    """
    global vector_db, image_vector_db, image_embedder, initialization_mode
    
    start_time = time.time()
    timing = {}
    
    # Check if system is initialized
    if initialization_mode == "none":
        raise HTTPException(
            status_code=503,
            detail="System not initialized. Please call /initialize endpoint first."
        )
    
    # Determine which database to use based on mode
    search_db = None
    use_real_embeddings = True
    
    if initialization_mode in ["high_resources", "low_res_pic"]:
        # Use image database and real embeddings
        if image_vector_db is None:
            raise HTTPException(
                status_code=503,
                detail="Image database not available. Please initialize system properly."
            )
        if image_embedder is None:
            raise HTTPException(
                status_code=503,
                detail="Image embedder not available. Please initialize system in 'high_resources' or 'low_res_pic' mode first."
            )
        search_db = image_vector_db
        use_real_embeddings = True
        
    elif initialization_mode == "random_pic":
        # Use image database with random vectors
        if image_vector_db is None:
            raise HTTPException(
                status_code=503,
                detail="Image database not available. Please initialize system in 'random_pic' mode first."
            )
        search_db = image_vector_db
        use_real_embeddings = False
        
    else:
        raise HTTPException(
            status_code=503,
            detail=f"Image search not supported in '{initialization_mode}' mode. Use 'high_resources', 'low_res_pic', or 'random_pic' mode."
        )
    
    # Validate uploaded file
    if not image.content_type or not image.content_type.startswith('image/'):
        raise HTTPException(
            status_code=400,
            detail="Uploaded file must be an image (JPEG, PNG, etc.)"
        )
    
    try:
        # Read and process the uploaded image
        image_processing_start = time.time()
        
        if use_real_embeddings:
            # Read image data
            image_data = await image.read()
            
            # Convert to PIL Image
            pil_image = Image.open(io.BytesIO(image_data)).convert('RGB')
            
            # Generate image embedding
            image_embedding = image_embedder.get_embedding(pil_image)
            
            # Convert to numpy array and then to list for search
            if hasattr(image_embedding, 'cpu'):
                embedding_vector = image_embedding.cpu().numpy().tolist()
            else:
                embedding_vector = image_embedding.tolist()
            
            # ResNet18 produces 512D embeddings for image database
            if len(embedding_vector) != 512:
                raise ValueError(f"Unexpected embedding dimension: {len(embedding_vector)}. Expected 512 for image embeddings.")
            
            timing["image_embedding"] = time.time() - image_processing_start
        else:
            # Use random vector for testing (512D for image database)
            embedding_vector = np.random.rand(512).tolist()
            timing["random_vector_generation"] = time.time() - image_processing_start
        
        # Validate embedding vector
        if not embedding_vector or any(not isinstance(x, (int, float)) for x in embedding_vector):
            raise ValueError("Invalid embedding vector: contains non-numeric values")
        
        print(f"Image embedding dimension: {len(embedding_vector)}, mode: {initialization_mode}")  # Debug log
        
        # Perform the search in image vector database
        search_start = time.time()
        results, search_timing = search_db.search_with_timing(embedding_vector, top_k=10)
        
        # Filter out non-numeric timing values to avoid validation errors
        filtered_timing = {k: v for k, v in search_timing.items() if isinstance(v, (int, float))}
        timing.update(filtered_timing)
        timing["total_search"] = time.time() - search_start
        
        # Convert results to response format
        fish_results = []
        for fish, score in results:
            fish_result = FishResult(
                id=fish.id,
                name=fish.name,
                similarity_score=float(score),
                genus=fish.genus if fish.genus else None,
                species=fish.species if fish.species else None,
                fbname=fish.fbname if fish.fbname else None,
                description=fish.full_description[:200] + "..." if len(fish.full_description) > 200 else fish.full_description
            )
            fish_results.append(fish_result)
        
        total_time = time.time() - start_time
        timing["total_request"] = total_time
        
        return ImageSearchResponse(
            success=True,
            results=fish_results,
            mode_used=f"{initialization_mode}_image_search",
            timing=timing,
            total_time=total_time
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Image search failed: {str(e)}"
        )


@app.get("/status", response_model=StatusResponse)
async def get_status():
    """Get current system status and initialization state"""
    global vector_db, image_vector_db, qwen_embedder, image_embedder, initialization_mode
    
    text_db_loaded = vector_db is not None
    image_db_loaded = image_vector_db is not None
    qwen_loaded = qwen_embedder is not None
    image_loaded = image_embedder is not None
    initialized = initialization_mode != "none"
    
    fish_count = 0
    if text_db_loaded:
        try:
            stats = vector_db.get_stats()
            fish_count += stats.get("qdrant_points", 0)
        except:
            pass
    
    if image_db_loaded:
        try:
            image_stats = image_vector_db.get_stats()
            fish_count += image_stats.get("qdrant_points", 0)
        except:
            pass
    
    status_msg = f"System status: {'initialized' if initialized else 'not initialized'}"
    if initialized:
        status_msg += f" (mode: {initialization_mode})"
    
    return StatusResponse(
        status="ready" if initialized else "not_initialized",
        initialized=initialized,
        mode=initialization_mode,
        text_database_loaded=text_db_loaded,
        image_database_loaded=image_db_loaded,
        qwen_loaded=qwen_loaded,
        image_embedder_loaded=image_loaded,
        fish_count=fish_count,
        message=status_msg
    )


@app.post("/predict")
async def predict(image: UploadFile = File(...)):
    """
    Mock ML model endpoint that always returns 'щука' (pike) as the prediction.
    Accepts any image data but ignores it and returns a fixed response.
    """
    # Check if file was uploaded
    if not image:
        raise HTTPException(status_code=400, detail="No image provided")
    
    # Mock prediction result - always returns щука
    result = {
        'prediction': 'Щука обыкновенная',
        'confidence': 0.95,
        'status': 'success'
    }
    
    return result


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        'status': 'healthy', 
        'service': 'FishMasters ML API',
        'initialized': initialization_mode != "none",
        'mode': initialization_mode
    }


@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        'message': 'FishMasters ML API',
        'version': '2.0.0',
        'endpoints': {
            'initialize': '/initialize (POST) - Initialize system with specified mode',
            'search': '/search (POST) - Search for fish by text description',
            'search_image': '/search_image (POST) - Search for fish by uploaded image',
            'status': '/status (GET) - Get system status',
            'predict': '/predict (POST) - Fish image prediction (mock)',
            'health': '/health (GET) - Health check',
            'docs': '/docs (GET) - API documentation'
        },
        'modes': {
            'low_resources': 'Use random vectors for text search only (fast, not semantic)',
            'low_res_pic': 'Use random vectors for text + ResNet18 for image search (moderate resources)',
            'random_pic': 'Use random vectors for image search only (testing mode)',
            'high_resources': 'Use Qwen embeddings for text + ResNet18 for image search (full functionality)'
        }
    }


if __name__ == '__main__':
    uvicorn.run(app, host='0.0.0.0', port=5001) 