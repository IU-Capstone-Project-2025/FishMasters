from typing import Dict, Any


class FishSpecies:
    """Represents fish species metadata based on UML diagram and CSV dataset"""
    def __init__(self, fish_id: int, name: str, russian_name: str = "", description: str = "", 
                 habitat: str = "", size: str = "", color: str = "", food_preferences: str = "", 
                 region: str = "", genus: str = "", species: str = "", fbname: str = "",
                 body_shape_i: str = "", length: str = "", weight: str = "", air_breathing: str = "",
                 longevity_wild: str = "", dangerous: str = "", fresh: str = "", brack: str = "",
                 saltwater: str = "", depth_range_shallow: str = "", depth_range_deep: str = "",
                 main_catching_method: str = "", comments: str = "", full_description: str = "",
                 image_path: str = ""):
        # UML diagram attributes
        self.id = fish_id
        self.name = name
        self.russian_name = russian_name
        self.description = description
        self.habitat = habitat
        self.size = size
        self.color = color
        self.food_preferences = food_preferences
        self.region = region
        
        # CSV dataset attributes
        self.genus = genus
        self.species = species
        self.fbname = fbname
        self.body_shape_i = body_shape_i
        self.length = length
        self.weight = weight
        self.air_breathing = air_breathing
        self.longevity_wild = longevity_wild
        self.dangerous = dangerous
        self.fresh = fresh
        self.brack = brack
        self.saltwater = saltwater
        self.depth_range_shallow = depth_range_shallow
        self.depth_range_deep = depth_range_deep
        self.main_catching_method = main_catching_method
        self.comments = comments
        self.full_description = full_description
        
        # Image-related attributes
        self.image_path = image_path
    
    def get_full_description(self) -> str:
        """Returns comprehensive description combining all available information"""
        description_parts = []
        
        if self.name:
            description_parts.append(f"Name: {self.name}")
        if self.genus and self.species:
            description_parts.append(f"Scientific Name: {self.genus} {self.species}")
        if self.full_description:
            description_parts.append(f"Full Description: {self.full_description}")
        if self.image_path:
            description_parts.append(f"Image Path: {self.image_path}")
        
        return "\n".join(description_parts)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert FishSpecies object to dictionary"""
        return {
            "id": self.id,
            "name": self.name,
            "russian_name": self.russian_name,
            "description": self.description,
            "habitat": self.habitat,
            "size": self.size,
            "color": self.color,
            "food_preferences": self.food_preferences,
            "region": self.region,
            "genus": self.genus,
            "species": self.species,
            "fbname": self.fbname,
            "body_shape_i": self.body_shape_i,
            "length": self.length,
            "weight": self.weight,
            "air_breathing": self.air_breathing,
            "longevity_wild": self.longevity_wild,
            "dangerous": self.dangerous,
            "fresh": self.fresh,
            "brack": self.brack,
            "saltwater": self.saltwater,
            "depth_range_shallow": self.depth_range_shallow,
            "depth_range_deep": self.depth_range_deep,
            "main_catching_method": self.main_catching_method,
            "comments": self.comments,
            "full_description": self.full_description,
            "image_path": self.image_path
        } 