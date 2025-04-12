from fastapi import APIRouter, Depends, HTTPException, Query, Header
from sqlalchemy.orm import Session
from typing import List, Optional
import database, models, schemas, sync
import uuid
import math
from geopy.distance import geodesic
import jwt
import os
from jwt.exceptions import PyJWTError

router = APIRouter()

# JWT verification
JWT_SECRET = os.getenv("JWT_SECRET", "dev_secret_change_in_production")

def get_user_id_from_token(authorization: Optional[str] = Header(None)):
    """Extract user_id and token from JWT if present, otherwise return None"""
    if not authorization:
        return None, None
    
    try:
        # Extract token from Bearer
        token = authorization.split("Bearer ")[1]
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        return payload.get("user_id"), token
    except (PyJWTError, IndexError, ValueError):
        # For restaurant endpoints, we don't require authentication
        # just return None if token is invalid
        return None, None

# Calculate distance between two coordinates
def calculate_distance(lat1, lon1, lat2, lon2):
    # Returns distance in meters
    return geodesic((lat1, lon1), (lat2, lon2)).meters

# Get all restaurants nearby
@router.get("/restaurants/nearby", response_model=List[schemas.Restaurant])
def get_nearby_restaurants(
    latitude: float,
    longitude: float,
    radius: int = 5000,
    db: Session = Depends(database.get_db),
    authorization: Optional[str] = Header(None)
):
    # Get user ID if authenticated
    user_id, token = get_user_id_from_token(authorization)
    user = None
    
    if user_id:
        # Get user
        user = db.query(models.User).filter(models.User.id == user_id).first()
        if not user:
            # Try to sync user from Go backend
            user = sync.sync_user_from_go_backend(db, user_id, token)
    
    # Get all restaurants
    restaurants = db.query(models.Restaurant).all()
    
    # Calculate distance for each and filter by radius
    result = []
    for restaurant in restaurants:
        distance = calculate_distance(
            latitude, longitude, 
            restaurant.latitude, restaurant.longitude
        )
        
        if distance <= radius:
            # Convert to schema
            restaurant_data = schemas.Restaurant.from_orm(restaurant)
            
            # Add distance to response
            restaurant_data.distance = distance
            
            # Check if restaurant is in user's favorites
            if user:
                restaurant_data.is_favorite = restaurant in user.favorites
            
            result.append(restaurant_data)
    
    # Sort by distance
    result.sort(key=lambda x: x.distance)
    
    return result

# Search restaurants
@router.get("/restaurants/search", response_model=List[schemas.Restaurant])
def search_restaurants(
    latitude: float,
    longitude: float,
    radius: int = 5000,
    query: Optional[str] = None,
    cuisine: Optional[str] = None,
    min_rating: Optional[int] = None,
    db: Session = Depends(database.get_db),
    authorization: Optional[str] = Header(None)
):
    # Get user ID if authenticated
    user_id, token = get_user_id_from_token(authorization)
    user = None
    
    if user_id:
        # Get user
        user = db.query(models.User).filter(models.User.id == user_id).first()
        if not user:
            # Try to sync user from Go backend
            user = sync.sync_user_from_go_backend(db, user_id, token)
    
    # Start with all restaurants
    restaurants_query = db.query(models.Restaurant)
    
    # Apply filters if provided
    if query:
        restaurants_query = restaurants_query.filter(
            models.Restaurant.name.ilike(f"%{query}%") |
            models.Restaurant.description.ilike(f"%{query}%")
        )
    
    if cuisine:
        restaurants_query = restaurants_query.filter(
            models.Restaurant.cuisine_type.ilike(f"%{cuisine}%")
        )
    
    if min_rating and min_rating > 0:
        restaurants_query = restaurants_query.filter(
            models.Restaurant.rating >= min_rating
        )
    
    if query == "vegan":
        restaurants_query = restaurants_query.filter(models.Restaurant.is_vegan == True)
    
    if query == "vegetarian":
        restaurants_query = restaurants_query.filter(models.Restaurant.is_vegetarian == True)
    
    restaurants = restaurants_query.all()
    
    # Calculate distance for each and filter by radius
    result = []
    for restaurant in restaurants:
        distance = calculate_distance(
            latitude, longitude, 
            restaurant.latitude, restaurant.longitude
        )
        
        if distance <= radius:
            # Convert to schema
            restaurant_data = schemas.Restaurant.from_orm(restaurant)
            
            # Add distance to response
            restaurant_data.distance = distance
            
            # Check if restaurant is in user's favorites
            if user:
                restaurant_data.is_favorite = restaurant in user.favorites
            
            result.append(restaurant_data)
    
    # Sort by distance
    result.sort(key=lambda x: x.distance)
    
    return result

# Get restaurant by ID
@router.get("/restaurants/{restaurant_id}", response_model=schemas.Restaurant)
def get_restaurant(
    restaurant_id: str,
    db: Session = Depends(database.get_db),
    authorization: Optional[str] = Header(None)
):
    # Get user ID if authenticated
    user_id, token = get_user_id_from_token(authorization)
    user = None
    
    if user_id:
        # Get user
        user = db.query(models.User).filter(models.User.id == user_id).first()
        if not user:
            # Try to sync user from Go backend
            user = sync.sync_user_from_go_backend(db, user_id, token)
    
    restaurant = db.query(models.Restaurant).filter(models.Restaurant.id == restaurant_id).first()
    
    if not restaurant:
        raise HTTPException(status_code=404, detail="Restaurant not found")
    
    # Convert to schema
    restaurant_data = schemas.Restaurant.from_orm(restaurant)
    
    # Check if restaurant is in user's favorites
    if user:
        restaurant_data.is_favorite = restaurant in user.favorites
    
    return restaurant_data

# Seed some example restaurants (for development)
@router.post("/restaurants/seed", status_code=201)
def seed_restaurants(db: Session = Depends(database.get_db)):
    # Check if we already have restaurants
    if db.query(models.Restaurant).count() > 0:
        return {"message": "Database already has restaurants"}
    
    # Example restaurant data
    restaurants = [
        {
            "name": "Green Garden",
            "address": "123 Plant Street, Veganville",
            "phone_number": "555-123-4567",
            "website": "https://greengarden.example.com",
            "cuisine_type": "Vegan Fusion",
            "description": "A fully vegan restaurant with plant-based options for everyone.",
            "latitude": 37.7749,
            "longitude": -122.4194,
            "rating": 4,
            "is_vegan": True,
            "is_vegetarian": True
        },
        {
            "name": "Veggie Delight",
            "address": "456 Vegetable Avenue, Greentown",
            "phone_number": "555-987-6543",
            "website": "https://veggiedelight.example.com",
            "cuisine_type": "Vegetarian",
            "description": "Vegetarian restaurant with some vegan options.",
            "latitude": 37.7739,
            "longitude": -122.4312,
            "rating": 3,
            "is_vegan": False,
            "is_vegetarian": True
        },
        {
            "name": "Plant Power",
            "address": "789 Earth Road, Eco City",
            "phone_number": "555-567-8901",
            "website": "https://plantpower.example.com",
            "cuisine_type": "Raw Vegan",
            "description": "Specializing in raw vegan cuisine and fresh juices.",
            "latitude": 37.7833,
            "longitude": -122.4167,
            "rating": 5,
            "is_vegan": True,
            "is_vegetarian": True
        }
    ]
    
    # Insert restaurants
    for restaurant_data in restaurants:
        restaurant = models.Restaurant(
            id=str(uuid.uuid4()),
            **restaurant_data
        )
        db.add(restaurant)
    
    db.commit()
    
    return {"message": "Restaurants added successfully"}
