from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import database
import models
import sync
import jwt
import os
from pydantic import BaseModel

router = APIRouter()

# JWT verification
JWT_SECRET = os.getenv("JWT_SECRET", "dev_secret_change_in_production")

class SyncRequest(BaseModel):
    token: str

@router.post("/sync")
def sync_user(
    request: SyncRequest,
    db: Session = Depends(database.get_db)
):
    try:
        # Decode token to get user info
        payload = jwt.decode(request.token, JWT_SECRET, algorithms=["HS256"])
        user_id = payload.get("user_id")
        
        if not user_id:
            raise HTTPException(status_code=400, detail="Invalid token")
        
        # Check if user exists
        user = db.query(models.User).filter(models.User.id == user_id).first()
        if not user:
            # Sync user from Go backend
            user = sync.sync_user_from_go_backend(db, user_id, request.token)
            if not user:
                raise HTTPException(status_code=404, detail="User not found in Go backend")
        
        return {"message": "User synced successfully"}
        
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid token") 