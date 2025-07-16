from typing import Dict
import faiss
import os
import numpy as np
from qdrant_client import QdrantClient
from qdrant_client.models import VectorParams, Distance
from dotenv import load_dotenv
import pickle
from PIL import Image
from embedder import Embedder
from fish_species import FishSpecies
import time

load_dotenv()
 
class PicSearchSystem:
    
    def __init__(self, collection_name: str = "fish_embeddings", faiss_index_path: str = "qdrant_faiss_pics_index.faiss"):
        qdrant_url = os.getenv("QDRANT_URL")
        qdrant_api_key = os.getenv("QDRANT_API_KEY")
    
        if not qdrant_url or not qdrant_api_key:
            raise ValueError("QDRANT_URL and QDRANT_API_KEY environment variables must be set")

        self.qdrant_client = QdrantClient(
            url=qdrant_url,
            api_key=qdrant_api_key,
        )
        self.collection_name = collection_name
        self.faiss_index_path = faiss_index_path
        self.metadata_path = faiss_index_path.replace('.faiss', '_metadata.pkl')
        
        self.faiss_index = None
        self.embedding_dims = 512
        
        self.embedder = Embedder()
         
        # Mapping between FAISS indices and Qdrant point IDs
        self.faiss_id_to_qdrant_id: Dict[int, int] = {}
        self.qdrant_id_to_faiss_id: Dict[int, int] = {}
        
        # Initialize components
        self._initialize_qdrant_collection()
        self._load_or_build_faiss_index()
        
    def _initialize_qdrant_collection(self):
        """Initialize the Qdrant collection for persistent storage"""
        try:
            collections = self.qdrant_client.get_collections()
            collection_names = [col.name for col in collections.collections]
            
            if self.collection_name not in collection_names:
                self.qdrant_client.create_collection(
                    collection_name=self.collection_name,
                    vectors_config=VectorParams(size=self.embedding_dimension, distance=Distance.COSINE)
                )
                print(f"Created Qdrant collection: {self.collection_name}")
            else:
                print(f"Qdrant collection {self.collection_name} already exists")
        except Exception as e:
            print(f"Error initializing Qdrant collection: {e}")
    
    def _load_or_build_faiss_index(self):
        """Load existing FAISS index or build it from Qdrant data"""
        try:
            # Try to load existing FAISS index
            if os.path.exists(self.faiss_index_path) and os.path.exists(self.metadata_path):
                print(f"Loading existing FAISS index from: {self.faiss_index_path}")
                self.faiss_index = faiss.read_index(self.faiss_index_path)
                
                with open(self.metadata_path, 'rb') as f:
                    mappings = pickle.load(f)
                    self.faiss_id_to_qdrant_id = mappings['faiss_id_to_qdrant_id']
                    self.qdrant_id_to_faiss_id = mappings['qdrant_id_to_faiss_id']
                
                print(f"Loaded FAISS index with {self.faiss_index.ntotal} vectors")
                
                # Verify index is still valid by checking Qdrant
                if not self._verify_faiss_index():
                    print("FAISS index is outdated, rebuilding from Qdrant...")
                    self._build_faiss_from_qdrant()
            else:
                print("No existing FAISS index found, building from Qdrant data...")
                self._build_faiss_from_qdrant()
                
        except Exception as e:
            print(f"Error loading FAISS index: {e}")
            print("Building new FAISS index from Qdrant data...")
            self._build_faiss_from_qdrant()
    
    def _verify_faiss_index(self) -> bool:
        """Verify that the FAISS index matches current Qdrant data"""
        try:
            # Get count from Qdrant
            qdrant_info = self.qdrant_client.get_collection(self.collection_name)
            qdrant_count = qdrant_info.points_count
            
            # Compare with FAISS count
            faiss_count = self.faiss_index.ntotal if self.faiss_index else 0
            
            print(f"Qdrant points: {qdrant_count}, FAISS vectors: {faiss_count}")
            
            # If counts don't match, index is outdated
            return qdrant_count == faiss_count
            
        except Exception as e:
            print(f"Error verifying FAISS index: {e}")
            return False
    
    def _build_faiss_from_qdrant(self):
        """Build FAISS index from all vectors in Qdrant using batch processing"""
        try:
            print("Building FAISS index from Qdrant data...")
            
            # Create new FAISS index
            
            self.faiss_index = faiss.IndexFlatIP(self.embedding_dimension)
            
            self.faiss_id_to_qdrant_id = {}
            self.qdrant_id_to_faiss_id = {}
            
            # Process in batches to avoid timeouts
            batch_size = 1000
            offset = None
            total_processed = 0
            faiss_id_counter = 0
            
            print(f"Processing in batches of {batch_size}...")
            
            while True:
                try:
                    # Get batch of points from Qdrant
                    scroll_result = self.qdrant_client.scroll(
                        collection_name=self.collection_name,
                        limit=batch_size,
                        offset=offset,
                        with_payload=False,  # We only need vectors for FAISS
                        with_vectors=True
                    )
                    
                    points, next_offset = scroll_result
                    
                    if not points:
                        break
                    
                    # Process this batch
                    vectors_to_add = []
                    qdrant_ids = []
                    
                    for point in points:
                        if point.vector:
                            # Normalize vector for cosine similarity
                            vector = np.array(point.vector, dtype=np.float32).reshape(1, -1)
                            # faiss.normalize_L2(vector)
                            
                            vectors_to_add.append(vector[0])
                            qdrant_ids.append(point.id)
                    
                    if vectors_to_add:
                        # Add batch to FAISS
                        vectors_matrix = np.array(vectors_to_add, dtype=np.float32)
                        self.faiss_index.train(vectors_matrix)
                        self.faiss_index.add(vectors_matrix)
                        self.faiss_index.nprobe = 3    
                        
                        # Build mappings for this batch
                        for i, qdrant_id in enumerate(qdrant_ids):
                            self.faiss_id_to_qdrant_id[faiss_id_counter] = qdrant_id
                            self.qdrant_id_to_faiss_id[qdrant_id] = faiss_id_counter
                            faiss_id_counter += 1
                        
                        total_processed += len(vectors_to_add)
                        print(f"Processed batch: {len(vectors_to_add)} vectors (total: {total_processed})")
                    
                    # Move to next batch
                    if next_offset is None:
                        break
                    offset = next_offset
                    
                except Exception as batch_error:
                    print(f"Error processing batch: {batch_error}")
                    if "timeout" in str(batch_error).lower():
                        print("Timeout encountered, trying smaller batch size...")
                        batch_size = max(100, batch_size // 2)
                        continue
                    else:
                        raise batch_error
            
            print(f"Built FAISS index with {total_processed} vectors")
            
            if total_processed > 0:
                # Save the index and mappings
                self._save_faiss_index()
                print("FAISS index saved successfully")
            else:
                print("No vectors found in Qdrant to build FAISS index")
                
        except Exception as e:
            print(f"Error building FAISS index from Qdrant: {e}")
            # Create empty index as fallback
            self.faiss_index = faiss.IndexFlatIP(self.embedding_dimension)
            print("Created empty index")
             
    def search_faiss(self, image):
        try:
            if self.faiss_index.ntotal == 0:
                print("FAISS index is empty")
                return []
                        
            image_embedding = self.embedder.get_embedding(image)

            similarity, faiss_id = self.faiss_index.search(image_embedding, 1)
        
            if faiss_id == -1:
                raise ValueError(f"Faiss index: {faiss_id}")
            
            qdrant_id = self.faiss_id_to_qdrant_id.get(faiss_id)
            
            if qdrant_id is None:
                raise ValueError(f"qdrant_id is {qdrant_id}")
            
            points = self.qdrant_client.retrieve(
                collection_name=self.collection_name,
                ids=list(qdrant_id),
                with_payload=True
            )
            
            if qdrant_id not in points:
                raise ValueError(f"No qdrant_id {qdrant_id} in qdrant database")
            
            point = points[0]
            payload = point.payload
            
            fish_species = FishSpecies(
                fish_id=payload.get("id", 0),
                name=payload.get("name", ""),
                genus=payload.get("genus", ""),
                species=payload.get("species", ""),
                full_description=payload.get("full_description", ""),
                fbname=payload.get("fbname", "")
            )
            
            result = (fish_species, similarity)
            return result 

        except Exception as e:
            print(f"Error searching with FAISS {e}")
    
    def search_qdrant(self, image):
        try:
            image_embedding = self.embedder.get_embedding(image)

            search_result = self.qdrant_client.search(
                collection_name=self.collection_name,
                query_vector=image_embedding,
                limit = 1,
                with_payload=True
            )[0]
            
            payload = search_result.payload
            fish_species = FishSpecies(
                fish_id=payload.get("id", 0),
                name=payload.get("name", ""),
                genus=payload.get("genus", ""),
                species=payload.get("species", ""),
                full_description=payload.get("full_description", ""),
                fbname=payload.get("fbname", "")
            )
            
            return fish_species
            
        except Exception as e:
            print(f"Error searching with QDrant {e}")
    
    def compare_searches(self, image):
        pic = get_user_pic()
        time_faiss_st = time.time()
        result_faiss = self.search_faiss(pic)
        time_faiss_end = time.time()
        print(f"FAISS:\n\ttime: {time_faiss_end-time_faiss_st}\n\tresult: {result_faiss}")
        time_qdrant_st = time.time()
        result_qdrant = self.search_qdrant(pic)
        time_qdrant_end = time.time()
        print(f"QDrant:\n\ttime: {time_qdrant_end-time_qdrant_st}\n\tresult: {result_qdrant}")
        
        
        
def get_user_pic():
    #TODO получить фотку от пользователя
    ...
