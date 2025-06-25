from typing import Dict, Any


class FishSpecies:
    """Represents fish species metadata based on UML diagram and CSV dataset"""
    def __init__(self, fish_id: int, name: str, russian_name: str = "", description: str = "", 
                 habitat: str = "", size: str = "", color: str = "", food_preferences: str = "", 
                 region: str = "", genus: str = "", species: str = "", fbname: str = "",
                 body_shape_i: str = "", length: str = "", weight: str = "", air_breathing: str = "",
                 longevity_wild: str = "", dangerous: str = "", fresh: str = "", brack: str = "",
                 saltwater: str = "", depth_range_shallow: str = "", depth_range_deep: str = "",
                 main_catching_method: str = "", comments: str = "", full_description: str = ""):
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
    
    def get_full_description(self) -> str:
        """Returns comprehensive description combining all available information"""
        description_parts = []
        
        if self.name:
            description_parts.append(f"Name: {self.name}")
        if self.russian_name:
            description_parts.append(f"Russian Name: {self.russian_name}")
        if self.genus and self.species:
            description_parts.append(f"Scientific Name: {self.genus} {self.species}")
        if self.description:
            description_parts.append(f"Description: {self.description}")
        if self.habitat:
            description_parts.append(f"Habitat: {self.habitat}")
        if self.size:
            description_parts.append(f"Size: {self.size}")
        if self.length:
            description_parts.append(f"Length: {self.length}")
        if self.weight:
            description_parts.append(f"Weight: {self.weight}")
        if self.color:
            description_parts.append(f"Color: {self.color}")
        if self.food_preferences:
            description_parts.append(f"Food Preferences: {self.food_preferences}")
        if self.region:
            description_parts.append(f"Region: {self.region}")
        if self.full_description:
            description_parts.append(f"Full Description: {self.full_description}")
        
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
            "full_description": self.full_description
        } 