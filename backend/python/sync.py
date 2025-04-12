import requests
from sqlalchemy.orm import Session
import models
import os
import jwt

# JWT secret key
JWT_SECRET = os.getenv("JWT_SECRET", "dev_secret_change_in_production")

def sync_user_from_go_backend(db: Session, user_id: str, token: str) -> models.User:
    """
    Create user in Python backend using JWT data
    Returns the user if successful, None if failed
    """
    try:
        # Decode JWT to get user info
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        
        # Get user data from JWT
        username = payload.get("username")
        email = payload.get("email")
        
        if not all([user_id, username, email]):
            print("Missing required user data in JWT")
            return None
            
        # Check if user exists in Python backend
        user = db.query(models.User).filter(models.User.id == user_id).first()
        
        if not user:
            # Create new user in Python backend
            user = models.User(
                id=user_id,
                username=username,
                email=email
            )
            db.add(user)
            db.commit()
            db.refresh(user)
        
        return user
        
    except Exception as e:
        print(f"Error creating user from JWT: {e}")
        return None 