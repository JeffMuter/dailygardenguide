package router

import (
	"net/http"
)

func SetupRoutes(mux *http.ServeMux) {
	// routes go here.
	mux.HandleFunc("/", handleHome)
}
