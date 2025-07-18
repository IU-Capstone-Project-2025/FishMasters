from typing import List, Dict, Any, Optional, Tuple
from qdrant_client import QdrantClient
from qdrant_client.models import VectorParams, Distance, PointStruct, Filter, FieldCondition, MatchValue
import faiss
import numpy as np
import pickle
import os
from fish_species import FishSpecies


class FaissFromQdrantDatabase:
    """Vector database that uses Qdrant as primary storage and builds FAISS index from Qdrant data"""
    
    def __init__(self, collection_name: str = "fish_embeddings", faiss_index_path: str = "qdrant_faiss_index.faiss", embedding_dimension: int = 1024):
        # Get Qdrant credentials from environment variables
        qdrant_url = os.getenv("QDRANT_URL")
        qdrant_api_key = os.getenv("QDRANT_API_KEY")
        
        if not qdrant_url or not qdrant_api_key:
            raise ValueError("QDRANT_URL and QDRANT_API_KEY environment variables must be set")
        
        # Initialize Qdrant client
        self.qdrant_client = QdrantClient(
            url=qdrant_url,
            api_key=qdrant_api_key,
        )
        self.collection_name = collection_name
        self.faiss_index_path = faiss_index_path
        self.metadata_path = faiss_index_path.replace('.faiss', '_metadata.pkl')
        
        # FAISS index for fast similarity search
        self.faiss_index = None
        self.embedding_dimension = embedding_dimension
        
        # Mapping between FAISS indices and Qdrant point IDs
        self.faiss_id_to_qdrant_id: Dict[int, int] = {}
        self.qdrant_id_to_faiss_id: Dict[int, int] = {}
        
        # Cache for frequently accessed metadata
        self.metadata_cache: Dict[int, FishSpecies] = {}
        
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
            
            # self.faiss_index = faiss.IndexFlatIP(self.embedding_dimension)
            self.quantizer = faiss.IndexFlatIP(self.embedding_dimension)
            self.faiss_index = faiss.IndexIVFFlat(self.quantizer, self.embedding_dimension, 256, faiss.METRIC_INNER_PRODUCT)
            
            
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
    
    def _normalize_vector(self, vector: List[float]) -> np.ndarray:
        """Normalize vector for cosine similarity in FAISS"""
        vec_array = np.array(vector, dtype=np.float32).reshape(1, -1)
        # L2 normalize for cosine similarity
        # faiss.normalize_L2(vec_array)
        return vec_array
    
    def search(self, query_embedding: List[float], top_k: int = 5) -> List[Tuple[FishSpecies, float]]:
        """
        Search for similar fish embeddings using FAISS, retrieve metadata from Qdrant
        
        Args:
            query_embedding: Vector to search for
            top_k: Number of top results to return
            
        Returns:
            List[Tuple[FishSpecies, float]]: List of (fish_species, similarity_score) tuples
        """
        try:
            if self.faiss_index.ntotal == 0:
                print("FAISS index is empty")
                return []
            
            # Normalize query vector
            normalized_query = self._normalize_vector(query_embedding)
            
            # Search in FAISS
            similarities, faiss_indices = self.faiss_index.search(normalized_query, top_k)
            
            # Get Qdrant IDs from FAISS results
            qdrant_ids = []
            valid_similarities = []
            
            for i, faiss_id in enumerate(faiss_indices[0]):
                if faiss_id != -1:  # Valid result
                    qdrant_id = self.faiss_id_to_qdrant_id.get(faiss_id)
                    if qdrant_id is not None:
                        qdrant_ids.append(qdrant_id)
                        valid_similarities.append(similarities[0][i])
            
            if not qdrant_ids:
                return []
            
            # Retrieve metadata from Qdrant
            results = []
            points = self.qdrant_client.retrieve(
                collection_name=self.collection_name,
                ids=qdrant_ids,
                with_payload=True
            )
            
            # Create results maintaining the order from FAISS
            qdrant_points_dict = {point.id: point for point in points}
            
            for i, qdrant_id in enumerate(qdrant_ids):
                if qdrant_id in qdrant_points_dict:
                    point = qdrant_points_dict[qdrant_id]
                    payload = point.payload
                    
                    fish_species = FishSpecies(
                        fish_id=payload.get("id", 0),
                        name=payload.get("name", ""),
                        genus=payload.get("genus", ""),
                        species=payload.get("species", ""),
                        full_description=payload.get("full_description", ""),
                        fbname=payload.get("fbname", "")
                    )
                    
                    similarity_score = valid_similarities[i]
                    results.append((fish_species, similarity_score))
            
            return results
            
        except Exception as e:
            print(f"Error searching embeddings: {e}")
            return []

    def search_with_timing(self, query_embedding: List[float], top_k: int = 5) -> Tuple[List[Tuple[FishSpecies, float]], Dict[str, float]]:
        """
        Search for similar fish embeddings with detailed timing information
        
        Args:
            query_embedding: Vector to search for
            top_k: Number of top results to return
            
        Returns:
            Tuple[List[Tuple[FishSpecies, float]], Dict[str, float]]: 
                (results, timing_info) where timing_info contains detailed breakdown
        """
        import time
        
        timing_info = {}
        total_start = time.time()
        
        try:
            if self.faiss_index.ntotal == 0:
                print("FAISS index is empty")
                return [], {"total_time": 0.0, "error": "empty_index"}
            
            # 1. Vector normalization timing
            normalize_start = time.time()
            normalized_query = self._normalize_vector(query_embedding)
            timing_info['vector_normalization'] = time.time() - normalize_start
            
            # 2. FAISS index search timing
            faiss_search_start = time.time()
            similarities, faiss_indices = self.faiss_index.search(normalized_query, top_k)
            timing_info['faiss_index_search'] = time.time() - faiss_search_start
            
            # 3. ID mapping and preparation timing
            mapping_start = time.time()
            qdrant_ids = []
            valid_similarities = []
            
            for i, faiss_id in enumerate(faiss_indices[0]):
                if faiss_id != -1:  # Valid result
                    qdrant_id = self.faiss_id_to_qdrant_id.get(faiss_id)
                    if qdrant_id is not None:
                        qdrant_ids.append(qdrant_id)
                        valid_similarities.append(similarities[0][i])
            timing_info['id_mapping_preparation'] = time.time() - mapping_start
            
            if not qdrant_ids:
                timing_info['total_time'] = time.time() - total_start
                return [], timing_info
            
            # 4. Qdrant metadata retrieval timing
            qdrant_retrieval_start = time.time()
            points = self.qdrant_client.retrieve(
                collection_name=self.collection_name,
                ids=qdrant_ids,
                with_payload=True
            )
            timing_info['qdrant_metadata_retrieval'] = time.time() - qdrant_retrieval_start
            
            # 5. Result processing and object creation timing
            result_processing_start = time.time()
            results = []
            qdrant_points_dict = {point.id: point for point in points}
            
            for i, qdrant_id in enumerate(qdrant_ids):
                if qdrant_id in qdrant_points_dict:
                    point = qdrant_points_dict[qdrant_id]
                    payload = point.payload
                    
                    fish_species = FishSpecies(
                        fish_id=payload.get("id", 0),
                        name=payload.get("name", ""),
                        genus=payload.get("genus", ""),
                        species=payload.get("species", ""),
                        full_description=payload.get("full_description", ""),
                        fbname=payload.get("fbname", "")
                    )
                    
                    similarity_score = float(valid_similarities[i])
                    results.append((fish_species, similarity_score))
            
            timing_info['result_processing'] = time.time() - result_processing_start
            timing_info['total_time'] = time.time() - total_start
            
            # Additional statistics
            timing_info['results_count'] = len(results)
            timing_info['qdrant_ids_found'] = len(qdrant_ids)
            timing_info['faiss_vectors_searched'] = self.faiss_index.ntotal
            
            return results, timing_info
            
        except Exception as e:
            timing_info['total_time'] = time.time() - total_start
            timing_info['error'] = str(e)
            print(f"Error searching embeddings: {e}")
            print(f"Error type: {type(e).__name__}")
            import traceback
            print(f"Full traceback: {traceback.format_exc()}")
            return [], timing_info
    
    def search_qdrant_only(self, query_embedding: List[float], top_k: int = 5) -> List[FishSpecies]:
        """
        Search using Qdrant directly (bypass FAISS)
        
        Args:
            query_embedding: Vector to search for
            top_k: Number of top results to return
            
        Returns:
            List[FishSpecies]: List of similar fish species
        """
        try:
            search_result = self.qdrant_client.search(
                collection_name=self.collection_name,
                query_vector=query_embedding,
                limit=top_k,
                with_payload=True
            )
            
            results = []
            for hit in search_result:
                payload = hit.payload
                fish_species = FishSpecies(
                    fish_id=payload.get("id", 0),
                    name=payload.get("name", ""),
                    genus=payload.get("genus", ""),
                    species=payload.get("species", ""),
                    full_description=payload.get("full_description", ""),
                    fbname=payload.get("fbname", "")
                )
                results.append(fish_species)
            
            return results
            
        except Exception as e:
            print(f"Error searching Qdrant: {e}")
            return []

    def search_qdrant_only_with_timing(self, query_embedding: List[float], top_k: int = 5) -> Tuple[List[FishSpecies], Dict[str, float]]:
        """
        Search using Qdrant directly with detailed timing information
        
        Args:
            query_embedding: Vector to search for
            top_k: Number of top results to return
            
        Returns:
            Tuple[List[FishSpecies], Dict[str, float]]: (results, timing_info)
        """
        import time
        
        timing_info = {}
        total_start = time.time()
        
        try:
            # 1. Qdrant search timing (includes vector similarity + metadata retrieval)
            qdrant_search_start = time.time()
            search_result = self.qdrant_client.search(
                collection_name=self.collection_name,
                query_vector=query_embedding,
                limit=top_k,
                with_payload=True
            )
            timing_info['qdrant_search_with_metadata'] = time.time() - qdrant_search_start
            
            # 2. Result processing timing
            result_processing_start = time.time()
            results = []
            for hit in search_result:
                payload = hit.payload
                fish_species = FishSpecies(
                    fish_id=payload.get("id", 0),
                    name=payload.get("name", ""),
                    genus=payload.get("genus", ""),
                    species=payload.get("species", ""),
                    full_description=payload.get("full_description", ""),
                    fbname=payload.get("fbname", "")
                )
                results.append(fish_species)
            timing_info['result_processing'] = time.time() - result_processing_start
            
            timing_info['total_time'] = time.time() - total_start
            timing_info['results_count'] = len(results)
            timing_info['method'] = 'qdrant_only'
            
            return results, timing_info
            
        except Exception as e:
            timing_info['total_time'] = time.time() - total_start
            timing_info['error'] = str(e)
            print(f"Error searching Qdrant: {e}")
            return [], timing_info
    
    def rebuild_faiss_index(self):
        """Manually rebuild FAISS index from current Qdrant data"""
        print("Manually rebuilding FAISS index from Qdrant...")
        self._build_faiss_from_qdrant()
    
    def _save_faiss_index(self):
        """Save FAISS index and mappings to disk"""
        try:
            # Save FAISS index
            faiss.write_index(self.faiss_index, self.faiss_index_path)
            
            # Save mappings
            mappings = {
                'faiss_id_to_qdrant_id': self.faiss_id_to_qdrant_id,
                'qdrant_id_to_faiss_id': self.qdrant_id_to_faiss_id
            }
            
            with open(self.metadata_path, 'wb') as f:
                pickle.dump(mappings, f)
            
            print(f"Saved FAISS index with {self.faiss_index.ntotal} vectors to: {self.faiss_index_path}")
            
        except Exception as e:
            print(f"Error saving FAISS index: {e}")
    
    def get_fish_count(self) -> int:
        """Get total number of stored fish embeddings from Qdrant"""
        try:
            collection_info = self.qdrant_client.get_collection(self.collection_name)
            return collection_info.points_count
        except:
            return 0
    
    def get_stats(self) -> Dict[str, Any]:
        """Get database statistics"""
        try:
            collection_info = self.qdrant_client.get_collection(self.collection_name)
            qdrant_count = collection_info.points_count
        except:
            qdrant_count = 0
        
        return {
            "qdrant_points": qdrant_count,
            "faiss_vectors": self.faiss_index.ntotal if self.faiss_index else 0,
            "qdrant_collection": self.collection_name,
            "faiss_index_path": self.faiss_index_path,
            "index_synchronized": qdrant_count == (self.faiss_index.ntotal if self.faiss_index else 0)
        }
    
    def benchmark_search(self, query_embedding: List[float], top_k: int = 5) -> Dict[str, Any]:
        """Benchmark search performance between FAISS and Qdrant"""
        import time
        
        # Benchmark FAISS (with Qdrant metadata retrieval)
        start_time = time.time()
        faiss_results = self.search(query_embedding, top_k)
        faiss_time = time.time() - start_time
        
        # Benchmark Qdrant only
        start_time = time.time()
        qdrant_results = self.search_qdrant_only(query_embedding, top_k)
        qdrant_time = time.time() - start_time
        
        return {
            "faiss_time_seconds": faiss_time,
            "qdrant_time_seconds": qdrant_time,
            "speedup": qdrant_time / faiss_time if faiss_time > 0 else float('inf'),
            "faiss_results_count": len(faiss_results),
            "qdrant_results_count": len(qdrant_results),
            "note": "FAISS time includes metadata retrieval from Qdrant"
        } 