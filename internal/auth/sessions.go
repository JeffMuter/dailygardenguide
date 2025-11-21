package auth

import (
	"fmt"
	"net/http"
	"time"

	"github.com/google/uuid"
)

var sessions = make(map[string]*Session)

type Session struct {
	email      string
	startTime  time.Time
	expiration time.Time
}

// createSession takes a user request and gives them a session
func createSession(w http.ResponseWriter) {
	unique := uuid.New().String()
	c := &http.Cookie{
		Name:     "dgg-session-id",
		Value:    unique, // generate a unique ID
		Expires:  time.Now().Add(24 * time.Hour),
		HttpOnly: true,
		Path:     "/",
	}

	hoursAfterStart := time.Hour * 5 // sets hours until auto-logout. can be modified.
	session := &Session{email: "", startTime: time.Now(), expiration: time.Now().Add(hoursAfterStart)}
	http.SetCookie(w, c)
	sessions[unique] = session
}

// checkAuth checks to see if the request has a valid session
func checkAuth(r *http.Request) bool {
	c, err := r.Cookie("dgg-session-id")
	if err != nil {
		fmt.Println("failed to find cookie in the user request for checkAuth")
		return false
	}

	// check if the cookie value exists in our sessions map. if it does, good. if not? not authorized.
	_, ok := sessions[c.Value]
	if !ok {
		return false
	}

	return true
}

// removeOldSessions runs every so often in main, meant to keep sessions clean
func RemoveOldSessions() {
	for key, session := range sessions {
		if time.Now().After(session.expiration) {
			delete(sessions, key)
		}
	}
}
