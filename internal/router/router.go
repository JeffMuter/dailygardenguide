package router

import (
	"dailygardenguide/internal/auth"
	"net/http"
)

func SetupRoutes(mux *http.ServeMux) {
	// routes go here.
	mux.HandleFunc("/", auth.AuthenticateRequest(handleHomePage))
	mux.HandleFunc("/login", handleLoginPage)
}
