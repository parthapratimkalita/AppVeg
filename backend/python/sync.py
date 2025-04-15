import requests
from sqlalchemy.orm import Session
import models
import os
import jwt
from datetime import datetime

# JWT secret key
JWT_SECRET = os.getenv("JWT_SECRET", "dev_secret_change_in_production")

def sync_user_from_go_backend(db: Session, user_id: str, token: str) -> models.User:
    """
    Create user in Python backend using JWT data from Go backend
    Returns the user if successful, None if failed
    """
    try:
        # Decode JWT to get user info
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        
        # Get user data from JWT
        username = payload.get("username")  # This is the email from Go backend
        name = payload.get("name")         # This is the display name
        email = payload.get("email")       # This is the email
        
        if not all([user_id, username, name, email]):
            print(f"Missing required user data in JWT. user_id: {user_id}, username: {username}, name: {name}, email: {email}")
            return None
            
        # Check if user exists in Python backend
        user = db.query(models.User).filter(models.User.id == user_id).first()
        
        if not user:
            print(f"Creating new user in Python backend: {username} ({name})")
            # Create new user in Python backend
            now = datetime.utcnow()
            user = models.User(
                id=user_id,
                username=username,  # Using email as username
                name=name,         # Using display name
                email=email,       # Using email
                created_at=now,    # Set creation time
                updated_at=now     # Set update time
            )
            db.add(user)
            db.commit()
            db.refresh(user)
        else:
            print(f"User already exists in Python backend: {username} ({name})")
            # Update the user's information
            user.username = username
            user.name = name
            user.email = email
            user.updated_at = datetime.utcnow()
            db.commit()
            db.refresh(user)
        
        return user
        
    except Exception as e:
        print(f"Error creating user from JWT: {e}")
        return None 