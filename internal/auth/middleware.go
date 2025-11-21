package auth

import "net/http"

func handleRequest(protectedHandler http.HandlerFunc) http.HandlerFunc {

	return func(w http.ResponseWriter, r *http.Request) {
		if !checkAuth(r) {
			return
		}
		protectedHandler(w, r)
	}
}
