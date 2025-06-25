from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

app = FastAPI(title="FishMasters ML Mock Model", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
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
    return {'status': 'healthy', 'service': 'FishMasters ML Mock Model'}

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        'message': 'FishMasters ML Mock Model API',
        'endpoints': {
            'predict': '/predict (POST)',
            'health': '/health (GET)',
            'docs': '/docs (GET)'
        }
    }

if __name__ == '__main__':
    uvicorn.run(app, host='0.0.0.0', port=5001) 