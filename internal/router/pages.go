package router

import (
	"dailygardenguide/internal/templates"
	"fmt"
	"net/http"
)

func handleHomePage(w http.ResponseWriter, r *http.Request) {
	if err := templates.Home().Render(r.Context(), w); err != nil {
		fmt.Printf("Error rendering home template: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
	}
}

func handleLoginPage(w http.ResponseWriter, r *http.Request) {
	if err := templates.AuthenticationPage().Render(r.Context(), w); err != nil {
		fmt.Printf("Error rendering login template: %v", err)
		http.Error(w, "internal server error", http.StatusInternalServerError)
	}
}
