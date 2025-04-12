from typing import List, Optional
from pydantic import BaseModel, HttpUrl\


class PhotoBase(BaseModel):
    url: str

class PhotoCreate(PhotoBase):
    pass

class Photo(PhotoBase):
    id: str
    restaurant_id: str
    
    class Config:
        from_attributes = True

class RestaurantBase(BaseModel):
    name: str
    address: str
    phone_number: Optional[str] = None
    website: Optional[str] = None
    cuisine_type: Optional[str] = None
    description: Optional[str] = None
    latitude: float
    longitude: float
    rating: int = 0
    is_vegan: bool = False
    is_vegetarian: bool = True

class RestaurantCreate(RestaurantBase):
    pass

class Restaurant(RestaurantBase):
    id: str
    photos: Optional[List[Photo]] = []
    distance: Optional[float] = None
    is_favorite: Optional[bool] = False
    
    class Config:
        from_attributes = True

class UserBase(BaseModel):
    username: str
    email: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: str
    
    class Config:
        from_attributes = True

class FavoriteBase(BaseModel):
    restaurant_id: str

class FavoriteCreate(FavoriteBase):
    pass

class FavoriteDelete(FavoriteBase):
    pass

class Favorite(FavoriteBase):
    user_id: str
    
    class Config:
        from_attributes = True

class SearchParams(BaseModel):
    latitude: float
    longitude: float
    radius: Optional[int] = 5000  # meters
    query: Optional[str] = None
    cuisine: Optional[str] = None
    min_rating: Optional[int] = None
    vegan_only: Optional[bool] = False
