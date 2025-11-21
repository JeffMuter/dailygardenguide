package auth

import (
	"fmt"
	"net/http"
)

// AuthenticateRequest checks if the user is currently logged in.
func AuthenticateRequest(protectedHandler http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if !checkAuth(r) {
			fmt.Printf("request failed authentication: %s\n", r.URL)
			http.Redirect(w, r, "/login", http.StatusSeeOther)
			return
		}
		protectedHandler(w, r)
	}
}
