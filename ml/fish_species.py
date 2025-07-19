from typing import Dict, Any


class FishSpecies:
    """Represents fish species metadata based on UML diagram and CSV dataset"""
    def __init__(self, fish_id: int, name: str, genus: str = "", species: str = "", fbname: str = "",
                 full_description: str = "", image_path: str = ""):
        # UML diagram attributes
        self.id = fish_id
        self.name = name
        
        # CSV dataset attributes
        self.genus = genus
        self.species = species
        self.fbname = fbname
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
            "genus": self.genus,
            "species": self.species,
            "fbname": self.fbname,
            "full_description": self.full_description,
            "image_path": self.image_path
        } 