from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from typing import List, Optional
import database
import models
import schemas
import os
import jwt
from jwt.exceptions import PyJWTError

router = APIRouter()

# JWT verification
JWT_SECRET = os.getenv("JWT_SECRET", "dev_secret_change_in_production")

# Verify JWT token and get user ID
def verify_token(authorization: Optional[str] = Header(None)):
    if not authorization:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    try:
        # Extract token from Bearer
        token = authorization.split("Bearer ")[1]
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        return payload.get("user_id")
    except (PyJWTError, IndexError):
        raise HTTPException(status_code=401, detail="Invalid authentication token")

# Get user favorites
@router.get("/favorites", response_model=List[schemas.Restaurant])
def get_favorites(
    db: Session = Depends(database.get_db),
    user_id: str = Depends(verify_token)
):
    # Get user
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        print("User not found")
        return []
    
    print(f'The user {user}')
    
    # Get favorite restaurants
    result = []
    for restaurant in user.favorites:
        # Convert to schema
        restaurant_data = schemas.Restaurant.from_orm(restaurant)
        restaurant_data.is_favorite = True
        result.append(restaurant_data)
    
    return result

# Add restaurant to favorites
@router.post("/favorites", status_code=201)
def add_favorite(
    favorite: schemas.FavoriteCreate,
    db: Session = Depends(database.get_db),
    user_id: str = Depends(verify_token)
):
    # Get user
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Get restaurant
    restaurant = db.query(models.Restaurant).filter(models.Restaurant.id == favorite.restaurant_id).first()
    if not restaurant:
        raise HTTPException(status_code=404, detail="Restaurant not found")
    
    # Check if already favorited
    if restaurant in user.favorites:
        return {"message": "Restaurant already in favorites"}
    
    # Add to favorites
    user.favorites.append(restaurant)
    db.commit()
    
    return {"restaurant_id": restaurant.id, "message": "Added to favorites"}

# Remove restaurant from favorites
@router.delete("/favorites/{restaurant_id}", status_code=200)
def remove_favorite(
    restaurant_id: str,
    db: Session = Depends(database.get_db),
    user_id: str = Depends(verify_token)
):
    # Get user
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Get restaurant
    restaurant = db.query(models.Restaurant).filter(models.Restaurant.id == restaurant_id).first()
    if not restaurant:
        raise HTTPException(status_code=404, detail="Restaurant not found")
    
    # Remove from favorites
    if restaurant in user.favorites:
        user.favorites.remove(restaurant)
        db.commit()
    
    return {"message": "Removed from favorites"}
