package main

import (
	"dailygardenguide/internal/auth"
	"dailygardenguide/internal/router"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

func main() {
	// Get configuration from environment
	port := getEnv("PORT", "8080")

	// Set up HTTP routes
	mux := http.NewServeMux()
	router.SetupRoutes(mux)

	// clears active user session evey 15min
	ticker := time.NewTicker(15 * time.Minute) // adjust interval as needed
	go func() {
		defer ticker.Stop()
		for range ticker.C {
			auth.RemoveOldSessions()
		}
	}()

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
