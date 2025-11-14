package main

import (
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

	// Serve static files
	fs := http.FileServer(http.Dir("./static"))
	mux.Handle("/static/", http.StripPrefix("/static/", fs))

	// Routes
	mux.HandleFunc("/", handleLanding)

	// Start server
	addr := fmt.Sprintf(":%s", port)
	log.Printf("Daily Garden Guide server starting on http://localhost%s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}

// Handler placeholders - to be implemented
func handleLanding(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	fmt.Fprintf(w, `
<!DOCTYPE html>
<html>
<head>
    <title>Daily Garden Guide</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1>Daily Garden Guide</h1>
    <p>Get personalized daily gardening tips based on your plants and local weather.</p>
    <p><em>Coming soon...</em></p>
</body>
</html>
	`)
}

// Helper function to get environment variable with default
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
