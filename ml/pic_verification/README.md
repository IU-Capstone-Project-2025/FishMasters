# Fish Image Processing Pipeline

This module provides functionality to download fish images from FishBase, generate embeddings using ResNet18, and store them in Qdrant vector database for image-based fish identification.

## Features

- **Image Download**: Download fish images from FishBase automatically
- **Image Embeddings**: Generate 512-dimensional embeddings using ResNet18 (ImageNet pretrained)
- **Vector Storage**: Store embeddings in Qdrant with fish metadata
- **Batch Processing**: Efficient batch processing with progress tracking
- **Error Handling**: Robust error handling for failed downloads and processing

## Quick Start

### 1. Setup Environment

Make sure you have the required environment variables set:

```bash
# Create .env file in the ml directory
echo "QDRANT_URL=https://your-cluster.qdrant.tech" >> ../env
echo "QDRANT_API_KEY=your-api-key-here" >> ../.env
```

### 2. Install Dependencies

```bash
pip install torch torchvision pillow pandas tqdm python-dotenv qdrant-client
```

### 3. Run the Pipeline

#### Option A: Interactive Script
```bash
python run_image_pipeline.py
```

#### Option B: Command Line
```bash
# Test with existing images (5 images)
python embedder.py --test-run

# Process all existing images
python embedder.py

# Download new images and process (50 images max)
python embedder.py --download-new --max-images 50

# Custom collection name
python embedder.py --collection-name my_fish_collection
```

## Components

### `embedder.py`
Main module containing:
- `Embedder` class: ResNet18-based image embedding generator
- `pic_from_fishbase()`: Downloads fish images from FishBase
- `pic_embeddings_to_qdrant()`: Uploads embeddings to Qdrant
- `pipeline()`: Complete end-to-end processing pipeline

### `run_image_pipeline.py`
Interactive script for easy pipeline execution with user-friendly menu.

## Image Processing Details

### Image Preprocessing
- Resize to 256x256 pixels
- Center crop to 224x224 pixels
- Normalize using ImageNet statistics
- Convert to RGB format

### Embedding Generation
- Uses ResNet18 pretrained on ImageNet
- Removes final classification layer (fc layer replaced with Identity)
- Generates 512-dimensional feature vectors
- Processes images in evaluation mode (no gradients)

### Fish Metadata
Each image embedding is stored with comprehensive metadata:
- Fish species information (genus, species, common name)
- Image processing details (model used, timestamp)
- Image file path for reference
- All available FishBase attributes

## Qdrant Collection Structure

### Collection Name
- Default: `fish_image_embeddings`
- Test mode: `fish_image_embeddings_test`
- Custom names supported via command line

### Vector Configuration
- Dimension: 512 (ResNet18 feature size)
- Distance metric: Cosine similarity
- Batch size: 100 embeddings per upload

### Payload Structure
```json
{
    "id": 1,
    "name": "Aaptosyax_grypus",
    "genus": "Aaptosyax",
    "species": "grypus",
    "fbname": "giant salmon carp",
    "full_description": "Image of Aaptosyax grypus (giant salmon carp)",
    "image_path": "/path/to/image.jpg",
    "data_type": "image_embedding",
    "embedding_model": "resnet18",
    "image_processed_at": "2025-01-15 10:30:45"
}
```

## Usage Examples

### Basic Processing
```python
from embedder import pipeline

# Process first 10 images from existing downloads
pipeline(max_images=10, download_new=False)
```

### Advanced Usage
```python
from embedder import Embedder, pic_from_fishbase, pic_embeddings_to_qdrant
from PIL import Image

# Initialize embedder
embedder = Embedder()

# Load and process single image
image = Image.open("fish_image.jpg")
embedding = embedder.get_embedding(image)

# Download fish data
fish_data = pic_from_fishbase(max_images=50, download_new=True)

# Process images and upload to custom collection
pipeline(
    max_images=100,
    collection_name="marine_fish_images",
    download_new=False
)
```

## Error Handling

The pipeline handles various error conditions:
- **Missing environment variables**: Clear setup instructions
- **Network issues**: Retry logic for downloads
- **Image processing errors**: Skip corrupted images with logging
- **Database errors**: Batch-level error handling with progress preservation

## Performance Considerations

### Memory Usage
- Images are processed one at a time to minimize memory usage
- Embeddings are uploaded in batches of 100
- GPU acceleration supported if CUDA is available

### Processing Speed
- Typical speed: ~2-5 images per second (CPU)
- GPU acceleration can improve speed significantly
- Network speed affects download time

### Storage Requirements
- Each embedding: ~2KB (512 floats + metadata)
- Image files: Variable (typically 10-100KB each)
- Qdrant storage overhead: Minimal

## Troubleshooting

### Common Issues

1. **Environment Variables Not Set**
   ```
   ERROR: Missing required environment variables!
   ```
   Solution: Create `.env` file with QDRANT_URL and QDRANT_API_KEY

2. **No Images Found**
   ```
   No fish data with images available. Exiting.
   ```
   Solution: Run with `--download-new` flag to download images first

3. **CUDA Out of Memory**
   ```
   RuntimeError: CUDA out of memory
   ```
   Solution: Use CPU processing or reduce batch size

4. **Network Timeouts**
   ```
   Error downloading image: timeout
   ```
   Solution: Check internet connection, will retry automatically

### Debug Mode
Enable verbose logging by setting environment variable:
```bash
export PYTORCH_VERBOSE=1
```

## Integration with Existing System

This module integrates with:
- **Text embeddings**: Complementary to Qwen text embeddings
- **FAISS indexing**: Can build FAISS indices from Qdrant data
- **Search API**: Image embeddings available via search endpoints

### Dual Search Capability
With both text and image embeddings, the system supports:
- Text-based fish search ("small red fish")
- Image-based fish search (upload fish photo)
- Hybrid search combining both modalities

## Future Enhancements

- [ ] Support for additional image models (EfficientNet, Vision Transformer)
- [ ] Image augmentation for improved robustness
- [ ] Automatic image quality assessment
- [ ] Multi-scale embedding generation
- [ ] Real-time image processing API endpoint 