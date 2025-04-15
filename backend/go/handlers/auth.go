package handlers

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v4"
	"github.com/vegfinder/auth/models"
)

// JWT secret key
var jwtSecret = []byte(getJWTSecret())

func getJWTSecret() string {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		// Default secret for development
		return "dev_secret_change_in_production"
	}
	return secret
}

// LoginRequest represents the request body for login
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// RegisterRequest represents the request body for registration
type RegisterRequest struct {
	Username string `json:"username" binding:"required"`  // This will be the email
	Name     string `json:"name" binding:"required"`      // This is the display name
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

// TokenResponse represents the response with JWT token
type TokenResponse struct {
	AccessToken string `json:"access_token"`
	TokenType   string `json:"token_type"`
	Username    string `json:"username"`  // This is the email
	Name        string `json:"name"`      // This is the display name
	UserID      string `json:"user_id"`
}

// Register handles user registration
func Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if user exists by email (which is used as username)
	_, err := models.GetUserByUsername(req.Email)
	if err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email already registered"})
		return
	}

	// Create user with email as username and provided name
	user, err := models.CreateUser(req.Email, req.Name, req.Email, req.Password)
	if err != nil {
		log.Printf("Error creating user: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	// Generate token for sync
	token, err := generateJWT(user)
	if err != nil {
		log.Printf("Error generating token for sync: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	// Sync user to Python backend
	syncErr := syncUserToPythonBackend(token)
	if syncErr != nil {
		log.Printf("Error syncing user to Python backend: %v", syncErr)
		// Don't fail registration if sync fails
	}

	// Return user data with token
	userResponse := user.ToUserResponse()
	c.JSON(http.StatusOK, gin.H{
		"id": userResponse.ID,
		"username": userResponse.Username,
		"name": userResponse.Name,
		"email": userResponse.Email,
		"created_at": userResponse.CreatedAt,
		"token": token,
	})
}

// Login handles user authentication
func Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get user by email (which is used as username)
	user, err := models.GetUserByUsername(req.Username)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	// Check password
	if !user.CheckPassword(req.Password) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	// Generate JWT token
	token, err := generateJWT(user)
	if err != nil {
		log.Printf("Error generating token: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, TokenResponse{
		AccessToken: token,
		TokenType:   "Bearer",
		Username:    user.Username,  // Return the email
		Name:        user.Name,      // Return the display name
		UserID:      user.ID,
	})
}

// GetUserProfile returns the user's profile
func GetUserProfile(c *gin.Context) {
	// Get user ID from JWT context
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// Get user
	user, err := models.GetUserByID(userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	c.JSON(http.StatusOK, user.ToUserResponse())
}

// UpdateUserProfile updates a user's profile information
func UpdateUserProfile(c *gin.Context) {
	// Get user ID from JWT context
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	var req struct {
		Username string `json:"username"`
		Email    string `json:"email"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update user
	user, err := models.UpdateUser(userID, req.Username, req.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user"})
		return
	}

	c.JSON(http.StatusOK, user.ToUserResponse())
}

// generateJWT creates a new JWT token for a user
func generateJWT(user *models.User) (string, error) {
	// Token expires in 24 hours
	expirationTime := time.Now().Add(24 * time.Hour)

	// Create claims
	claims := jwt.MapClaims{
		"user_id":  user.ID,
		"username": user.Username,  // This is the email
		"name":     user.Name,      // This is the display name
		"email":    user.Email,     // This is the email
		"exp":      expirationTime.Unix(),
	}

	// Create token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	// Sign token
	tokenString, err := token.SignedString(jwtSecret)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

// Add sync function
func syncUserToPythonBackend(token string) error {
	client := &http.Client{}
	
	// Create request body
	requestBody := map[string]string{
		"token": token,
	}
	jsonBody, err := json.Marshal(requestBody)
	if err != nil {
		return err
	}
	
	// Create request
	req, err := http.NewRequest("POST", "http://localhost:8000/api/sync", bytes.NewBuffer(jsonBody))
	if err != nil {
		return err
	}
	
	// Add headers
	req.Header.Add("Content-Type", "application/json")
	
	// Send request
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("sync failed with status: %d", resp.StatusCode)
	}
	
	return nil
}
