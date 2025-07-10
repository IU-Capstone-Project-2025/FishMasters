# FishMasters ML API

A powerful fish search API that supports both fast random-vector search (low resources) and semantic search using Qwen embeddings (high resources).

## Features

- **Two Search Modes:**
  - **Low Resources**: Fast search using random vectors (for testing or resource-constrained environments)
  - **High Resources**: Semantic search using Qwen embeddings for accurate text-to-fish matching

- **FAISS Integration**: Fast similarity search using FAISS indices built from Qdrant data
- **RESTful API**: FastAPI-based REST API with automatic documentation
- **Flexible Initialization**: Choose your mode based on available resources
- **Comprehensive Timing**: Detailed performance metrics for all operations

## Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Set Environment Variables

Create a `.env` file with your Qdrant credentials:

```env
QDRANT_URL=your_qdrant_url
QDRANT_API_KEY=your_qdrant_api_key
```

### 3. Start the API Server

```bash
python app.py
```

The server will start on `http://localhost:5001`

### 4. Initialize the System

Choose your mode based on available resources:

**Low Resources Mode (Fast, Random Vectors)**
```bash
curl -X POST "http://localhost:5001/initialize" \
  -H "Content-Type: application/json" \
  -d '{"mode": "low_resources"}'
```

**High Resources Mode (Semantic Search)**
```bash
curl -X POST "http://localhost:5001/initialize" \
  -H "Content-Type: application/json" \
  -d '{"mode": "high_resources"}'
```

### 5. Search for Fish

```bash
curl -X POST "http://localhost:5001/search" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "large predatory fish with sharp teeth",
    "top_k": 5,
    "mode": "auto"
  }'
```

## API Endpoints

### POST `/initialize`

Initialize the system with a specific mode.

**Request Body:**
```json
{
  "mode": "low_resources" | "high_resources"
}
```

**Response:**
```json
{
  "status": "success",
  "initialized": true,
  "mode": "high_resources",
  "database_loaded": true,
  "qwen_loaded": true,
  "fish_count": 1234,
  "message": "System initialized in high_resources mode in 15.23 seconds"
}
```

### POST `/search`

Search for fish based on text description.

**Request Body:**
```json
{
  "description": "large predatory fish with sharp teeth",
  "top_k": 5,
  "mode": "auto" | "low_resources" | "high_resources"
}
```

**Response:**
```json
{
  "success": true,
  "results": [
    {
      "id": 123,
      "name": "Great White Shark",
      "similarity_score": 0.8765,
      "genus": "Carcharodon",
      "species": "carcharias",
      "fbname": "White shark",
      "description": "Large predatory shark with powerful jaws..."
    }
  ],
  "query": "large predatory fish with sharp teeth",
  "mode_used": "high_resources",
  "timing": {
    "text_embedding": 0.001234,
    "faiss_index_search": 0.000456,
    "qdrant_metadata_retrieval": 0.002345,
    "total_search": 0.004567,
    "total_request": 0.005678
  },
  "total_time": 0.005678
}
```

### GET `/status`

Get current system status.

**Response:**
```json
{
  "status": "ready",
  "initialized": true,
  "mode": "high_resources",
  "database_loaded": true,
  "qwen_loaded": true,
  "fish_count": 1234,
  "message": "System status: initialized (mode: high_resources)"
}
```

### GET `/health`

Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "service": "FishMasters ML API",
  "initialized": true,
  "mode": "high_resources"
}
```

## Usage Examples

### Python Client

Use the provided example client:

```python
from example_usage import FishSearchClient

client = FishSearchClient()

# Initialize system
client.initialize_system("high_resources")

# Search for fish
result = client.search_fish("colorful tropical fish", top_k=3)
print(f"Found {len(result['results'])} fish")
```

### Run Complete Demo

```bash
python example_usage.py
```

This will run a comprehensive demo showing both modes and their differences.

## Search Modes Comparison

| Feature | Low Resources | High Resources |
|---------|---------------|----------------|
| **Initialization Time** | ~1-2 seconds | ~10-30 seconds |
| **Search Speed** | Very Fast (~0.001s) | Fast (~0.1s) |
| **Semantic Understanding** | None (random) | Excellent |
| **Memory Usage** | Low | High |
| **Dependencies** | Minimal | Requires PyTorch + Transformers |
| **Use Case** | Testing, demos | Production, accurate search |

## Performance Tips

1. **For Production**: Use `high_resources` mode for best search quality
2. **For Testing**: Use `low_resources` mode for fast iteration
3. **Batch Searches**: The system maintains state between searches for efficiency
4. **Resource Planning**: High resources mode requires ~2-4GB RAM for Qwen model

## Error Handling

The API provides detailed error messages:

- `400`: Invalid request parameters
- `500`: Internal server errors (database, model loading)
- `503`: Service unavailable (system not initialized)

## Interactive Documentation

Visit `http://localhost:5001/docs` for interactive Swagger UI documentation where you can test all endpoints directly from your browser.

## Troubleshooting

### Common Issues

1. **"System not initialized"**: Call `/initialize` endpoint first
2. **Qwen model loading fails**: Check available memory and PyTorch installation
3. **Database connection issues**: Verify Qdrant credentials in `.env` file
4. **Slow search performance**: Ensure FAISS indices are properly built

### Debug Mode

Set environment variable for detailed logging:
```bash
export DEBUG=1
python app.py
```

## Architecture

The API is built on:
- **FastAPI**: Modern Python web framework
- **FAISS**: Fast similarity search
- **Qdrant**: Vector database for persistent storage
- **Qwen**: State-of-the-art text embedding model
- **Pydantic**: Data validation and serialization 