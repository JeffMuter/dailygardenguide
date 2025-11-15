package router

import (
	"dailygardenguide/internal/templates"
	"net/http"
)

func handleHome(w http.ResponseWriter, r *http.Request) {
	templates.Home().Render(r.Context(), w)
}
