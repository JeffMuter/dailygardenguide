package main

import (
	"dailygardenguide/internal/router"
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	// Get configuration from environment
	port := getEnv("PORT", "8080")

	// Set up HTTP routes
	mux := http.NewServeMux()
	router.SetupRoutes(mux)

	// Serve static files
	fs := http.FileServer(http.Dir("./static"))
	mux.Handle("/static/", http.StripPrefix("/static/", fs))

	// Start server
	addr := fmt.Sprintf(":%s", port)
	log.Printf("Daily Garden Guide server starting on http://localhost%s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}

// Helper function to get environment variable with default
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
