package main

import (
	"log"
	
	"os"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/vegfinder/auth/handlers"
	"github.com/vegfinder/auth/middleware"
	"github.com/vegfinder/auth/models"
)

func main() {
	// Initialize database connection
	err := models.InitDB()
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// Set up Gin router
	r := gin.Default()

	// Configure CORS
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	// Public routes
	auth := r.Group("/auth")
	{
		auth.POST("/register", handlers.Register)
		auth.POST("/login", handlers.Login)
	}

	// Protected routes
	profile := r.Group("/auth")
	profile.Use(middleware.JWTAuth())
	{
		profile.GET("/profile", handlers.GetUserProfile)
		profile.PUT("/profile", handlers.UpdateUserProfile)
	}

	// Start server
	port := os.Getenv("AUTH_PORT")
	if port == "" {
		port = "8085"
	}

	log.Printf("Starting auth server on port %s", port)
	if err := r.Run("0.0.0.0:" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
