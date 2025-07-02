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

        
        # CSV dataset attributes
        self.genus = genus
        self.species = species
        self.fbname = fbname
        self.full_description = full_description
    
    def get_full_description(self) -> str:
        """Returns comprehensive description combining all available information"""
        description_parts = []
        
        if self.name:
            description_parts.append(f"Name: {self.name}")
        if self.genus and self.species:
            description_parts.append(f"Scientific Name: {self.genus} {self.species}")
        if self.full_description:
            description_parts.append(f"Full Description: {self.full_description}")
        if self.full_description:
            description_parts.append(f"Full Description: {self.full_description}")
        
        return "\n".join(description_parts)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert FishSpecies object to dictionary"""
        return {
            "id": self.id,
            "name": self.name,
            "full_description": self.full_description,
            "genus": self.genus,
            "species": self.species,
            "fbname": self.fbname,
            
        } 