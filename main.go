package main

import (
	"log"
	"net/http"
)

func main() {
	log.Println("Initializing Argus Auth Service...")
	// Handle the /auth endpoint
	http.HandleFunc("/auth", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
			return
		}

		// Parse the form data
		if err := r.ParseForm(); err != nil {
			http.Error(w, "Bad Request", http.StatusBadRequest)
			return
		}

		// Extract the stream key from the form data
		streamKey := r.FormValue("key")

		// Check if the key is valid
		if streamKey == "supersecret" {
			w.WriteHeader(http.StatusOK)
			return
		}

		// Reject if the key doesn't match
		http.Error(w, "Forbidden", http.StatusForbidden)
	})

	log.Println("Argus Service Online.")
	log.Fatal(http.ListenAndServe(":8000", nil))
}
