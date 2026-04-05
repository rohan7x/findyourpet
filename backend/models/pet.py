# models/pet.py
from pydantic import BaseModel

class Pet(BaseModel):
    color: str
    breed: str
    image_url: str
    latitude: float
    longitude: float
    status: str  # "lost" or "found"
