package router

import (
	"dailygardenguide/internal/templates"
	"log"
	"net/http"
)

func handleHome(w http.ResponseWriter, r *http.Request) {
	if err := templates.Home().Render(r.Context(), w); err != nil {
		log.Printf("Error rendering home template: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
	}
}
