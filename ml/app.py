from fastapi import FastAPI, HTTPException, UploadFile, File, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import uvicorn
import numpy as np
import time
import os
from dotenv import load_dotenv

# Import our fish search components
from faiss_from_qdrant import FaissFromQdrantDatabase
from qwen_embeddings import QwenEmbedder
from fish_species import FishSpecies

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
qwen_embedder: Optional[QwenEmbedder] = None
initialization_mode: str = "none"  # "none", "low_resources", "high_resources"


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
    database_loaded: bool
    qwen_loaded: bool
    fish_count: int
    message: str


def initialize_database():
    """Initialize the FAISS vector database"""
    global vector_db
    
    try:
        if vector_db is None:
            print("🗄️ Initializing FAISS database...")
            vector_db = FaissFromQdrantDatabase(
                collection_name="fish_embeddings_20250627_102709",
                faiss_index_path="qdrant_faiss_index.faiss"
            )
            print("✅ Database initialized successfully")
        return True
    except Exception as e:
        print(f"❌ Failed to initialize database: {e}")
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


@app.post("/initialize", response_model=StatusResponse)
async def initialize_system(request: InitializationRequest):
    """
    Initialize the fish search system with specified mode.
    
    - **low_resources**: Only initialize the database, use random vectors for search
    - **high_resources**: Initialize both database and Qwen embeddings for semantic search
    """
    global initialization_mode
    
    mode = request.mode.lower()
    if mode not in ["low_resources", "high_resources"]:
        raise HTTPException(
            status_code=400, 
            detail="Mode must be 'low_resources' or 'high_resources'"
        )
    
    start_time = time.time()
    
    try:
        # Always initialize the database
        db_success = initialize_database()
        if not db_success:
            raise HTTPException(
                status_code=500,
                detail="Failed to initialize vector database"
            )
        
        qwen_success = True
        if mode == "high_resources":
            qwen_success = initialize_qwen_embedder()
            if not qwen_success:
                raise HTTPException(
                    status_code=500,
                    detail="Failed to initialize Qwen embeddings model"
                )
        
        initialization_mode = mode
        init_time = time.time() - start_time
        
        # Get database stats
        stats = vector_db.get_stats() if vector_db else {"qdrant_points": 0}
        fish_count = stats.get("qdrant_points", 0)
        
        return StatusResponse(
            status="success",
            initialized=True,
            mode=mode,
            database_loaded=db_success,
            qwen_loaded=(qwen_embedder is not None),
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
    - **low_resources**: Uses random vectors for search (fast but not semantic)
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
    elif requested_mode in ["low_resources", "high_resources"]:
        mode_used = requested_mode
    else:
        raise HTTPException(
            status_code=400,
            detail="Mode must be 'low_resources', 'high_resources', or 'auto'"
        )
    
    # Check if requested mode is available
    if mode_used == "high_resources" and qwen_embedder is None:
        if initialization_mode == "low_resources":
            mode_used = "low_resources"
        else:
            raise HTTPException(
                status_code=503,
                detail="High resources mode requested but Qwen embedder not available. Initialize system first or use low_resources mode."
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
        timing.update(search_timing)
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


@app.get("/status", response_model=StatusResponse)
async def get_status():
    """Get current system status and initialization state"""
    global vector_db, qwen_embedder, initialization_mode
    
    db_loaded = vector_db is not None
    qwen_loaded = qwen_embedder is not None
    initialized = initialization_mode != "none"
    
    fish_count = 0
    if db_loaded:
        try:
            stats = vector_db.get_stats()
            fish_count = stats.get("qdrant_points", 0)
        except:
            fish_count = 0
    
    status_msg = f"System status: {'initialized' if initialized else 'not initialized'}"
    if initialized:
        status_msg += f" (mode: {initialization_mode})"
    
    return StatusResponse(
        status="ready" if initialized else "not_initialized",
        initialized=initialized,
        mode=initialization_mode,
        database_loaded=db_loaded,
        qwen_loaded=qwen_loaded,
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
            'status': '/status (GET) - Get system status',
            'predict': '/predict (POST) - Fish image prediction (mock)',
            'health': '/health (GET) - Health check',
            'docs': '/docs (GET) - API documentation'
        },
        'modes': {
            'low_resources': 'Use random vectors for search (fast, not semantic)',
            'high_resources': 'Use Qwen embeddings for semantic search (accurate, slower)'
        }
    }


if __name__ == '__main__':
    uvicorn.run(app, host='0.0.0.0', port=5001) 