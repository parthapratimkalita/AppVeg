from sqlalchemy import Boolean, Column, Float, ForeignKey, Integer, String, Table, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base

# Association table for user favorites
user_favorites = Table(
    "user_favorites",
    Base.metadata,
    Column("user_id", String, ForeignKey("users.id"), primary_key=True),
    Column("restaurant_id", String, ForeignKey("restaurants.id"), primary_key=True),
)

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    name = Column(String)
    email = Column(String, unique=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationship to restaurants
    favorites = relationship("Restaurant", secondary=user_favorites, back_populates="favorited_by")

class Restaurant(Base):
    __tablename__ = "restaurants"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, index=True)
    address = Column(String)
    phone_number = Column(String, nullable=True)
    website = Column(String, nullable=True)
    cuisine_type = Column(String, nullable=True)
    description = Column(String, nullable=True)
    latitude = Column(Float)
    longitude = Column(Float)
    rating = Column(Integer, default=0)  # 0-5 scale
    is_vegan = Column(Boolean, default=False)
    is_vegetarian = Column(Boolean, default=True)
    
    # Photos
    photos = relationship("Photo", back_populates="restaurant")
    
    # Relationship to users
    favorited_by = relationship("User", secondary=user_favorites, back_populates="favorites")

class Photo(Base):
    __tablename__ = "photos"

    id = Column(String, primary_key=True, index=True)
    url = Column(String)
    restaurant_id = Column(String, ForeignKey("restaurants.id"))
    
    # Relationship to restaurant
    restaurant = relationship("Restaurant", back_populates="photos")
