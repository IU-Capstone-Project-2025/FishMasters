from typing import List, Dict, Any, Optional
from qdrant_client import QdrantClient
from qdrant_client.models import VectorParams, Distance, PointStruct, Filter, FieldCondition, MatchValue
import uuid
import os
from fish_species import FishSpecies



class VectorDatabase:
    """Vector database for fish embeddings and species metadata"""
    
    def __init__(self, collection_name: str = "fish_embeddings"):
        # Get Qdrant credentials from environment variables
        qdrant_url = os.getenv("QDRANT_URL")
        qdrant_api_key = os.getenv("QDRANT_API_KEY")
        
        if not qdrant_url or not qdrant_api_key:
            raise ValueError("QDRANT_URL and QDRANT_API_KEY environment variables must be set")
        
        # Initialize Qdrant client with environment variables
        self.client = QdrantClient(
            url=qdrant_url,
            api_key=qdrant_api_key,
        )
        self.collection_name = collection_name
        
        # Storage maps
        self.fish_embeddings: Dict[int, List[float]] = {}
        self.species_metadata: Dict[int, FishSpecies] = {}
        
        # Initialize collection if it doesn't exist
        self._initialize_collection()
    
    def _initialize_collection(self):
        """Initialize the Qdrant collection for fish embeddings"""
        try:
            collections = self.client.get_collections()
            collection_names = [col.name for col in collections.collections]
            
            if self.collection_name not in collection_names:
                # Create collection with vector configuration
                # Using 1024-dimensional vectors based on the CSV embedding format
                self.client.create_collection(
                    collection_name=self.collection_name,
                    vectors_config=VectorParams(size=1024, distance=Distance.COSINE)
                )
                print(f"Created collection: {self.collection_name}")
            else:
                print(f"Collection {self.collection_name} already exists")
        except Exception as e:
            print(f"Error initializing collection: {e}")
    
    def store(self, embedding: List[float], metadata: FishSpecies) -> int:
        """
        Store fish embedding with metadata in the vector database
        
        Args:
            embedding: Vector embedding of the fish
            metadata: FishSpecies object containing fish information
            
        Returns:
            int: Unique ID of the stored embedding
        """
        try:
            # Generate unique ID
            fish_id = len(self.fish_embeddings) + 1
            
            # Store in local maps
            self.fish_embeddings[fish_id] = embedding
            self.species_metadata[fish_id] = metadata
            
            # Create point for Qdrant
            point = PointStruct(
                id=fish_id,
                vector=embedding,
                payload=metadata.to_dict()
            )
            
            # Insert into Qdrant
            self.client.upsert(
                collection_name=self.collection_name,
                points=[point]
            )
            
            print(f"Stored fish embedding with ID: {fish_id}")
            return fish_id
            
        except Exception as e:
            print(f"Error storing embedding: {e}")
            return -1
    
    def search(self, query_embedding: List[float], top_k: int = 5) -> List[FishSpecies]:
        """
        Search for similar fish embeddings
        
        Args:
            query_embedding: Vector to search for
            top_k: Number of top results to return
            
        Returns:
            List[FishSpecies]: List of similar fish species
        """
        try:
            # Search in Qdrant
            search_result = self.client.search(
                collection_name=self.collection_name,
                query_vector=query_embedding,
                limit=top_k,
                with_payload=True
            )
            
            # Convert results to FishSpecies objects
            results = []
            for hit in search_result:
                payload = hit.payload
                fish_species = FishSpecies(
                    fish_id=payload.get("id", 0),
                    name=payload.get("name", ""),
                    russian_name=payload.get("russian_name", ""),
                    description=payload.get("description", ""),
                    habitat=payload.get("habitat", ""),
                    size=payload.get("size", ""),
                    color=payload.get("color", ""),
                    food_preferences=payload.get("food_preferences", ""),
                    region=payload.get("region", ""),
                    genus=payload.get("genus", ""),
                    species=payload.get("species", ""),
                    fbname=payload.get("fbname", ""),
                    body_shape_i=payload.get("body_shape_i", ""),
                    length=payload.get("length", ""),
                    weight=payload.get("weight", ""),
                    air_breathing=payload.get("air_breathing", ""),
                    longevity_wild=payload.get("longevity_wild", ""),
                    dangerous=payload.get("dangerous", ""),
                    fresh=payload.get("fresh", ""),
                    brack=payload.get("brack", ""),
                    saltwater=payload.get("saltwater", ""),
                    depth_range_shallow=payload.get("depth_range_shallow", ""),
                    depth_range_deep=payload.get("depth_range_deep", ""),
                    main_catching_method=payload.get("main_catching_method", ""),
                    comments=payload.get("comments", ""),
                    full_description=payload.get("full_description", "")
                )
                results.append(fish_species)
            
            return results
            
        except Exception as e:
            print(f"Error searching embeddings: {e}")
            return []
    
    def update_embedding(self, fish_id: int, embedding: List[float]) -> bool:
        """
        Update an existing fish embedding
        
        Args:
            fish_id: ID of the fish to update
            embedding: New vector embedding
            
        Returns:
            bool: True if update successful, False otherwise
        """
        try:
            if fish_id not in self.fish_embeddings:
                print(f"Fish ID {fish_id} not found")
                return False
            
            # Update local storage
            self.fish_embeddings[fish_id] = embedding
            
            # Get existing metadata
            metadata = self.species_metadata.get(fish_id)
            if not metadata:
                print(f"No metadata found for fish ID {fish_id}")
                return False
            
            # Update in Qdrant
            point = PointStruct(
                id=fish_id,
                vector=embedding,
                payload=metadata.to_dict()
            )
            
            self.client.upsert(
                collection_name=self.collection_name,
                points=[point]
            )
            
            print(f"Updated embedding for fish ID: {fish_id}")
            return True
            
        except Exception as e:
            print(f"Error updating embedding: {e}")
            return False
    
    def delete_embedding(self, fish_id: int) -> bool:
        """
        Delete a fish embedding and its metadata
        
        Args:
            fish_id: ID of the fish to delete
            
        Returns:
            bool: True if deletion successful, False otherwise
        """
        try:
            if fish_id not in self.fish_embeddings:
                print(f"Fish ID {fish_id} not found")
                return False
            
            # Remove from local storage
            del self.fish_embeddings[fish_id]
            del self.species_metadata[fish_id]
            
            # Delete from Qdrant
            self.client.delete(
                collection_name=self.collection_name,
                points_selector=[fish_id]
            )
            
            print(f"Deleted fish embedding with ID: {fish_id}")
            return True
            
        except Exception as e:
            print(f"Error deleting embedding: {e}")
            return False
    
    def get_fish_count(self) -> int:
        """Get total number of stored fish embeddings"""
        return len(self.fish_embeddings)
    
    def get_all_species(self) -> List[FishSpecies]:
        """Get all stored fish species metadata"""
        return list(self.species_metadata.values())
    
    def search_by_species_name(self, species_name: str) -> Optional[FishSpecies]:
        """Search for fish by species name"""
        for metadata in self.species_metadata.values():
            if metadata.name.lower() == species_name.lower():
                return metadata
        return None 