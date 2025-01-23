# --------------------------------------------------
# Build Stage
# --------------------------------------------------
    FROM ubuntu:24.04 AS builder

    # Set noninteractive mode for apt
    ENV DEBIAN_FRONTEND=noninteractive
    
    # Install Go and any necessary build tools
    RUN apt-get update && \
        apt-get install -y golang ca-certificates && \
        rm -rf /var/lib/apt/lists/*
    
    # Create working directory
    WORKDIR /app
    
    # Copy Go module definitions & download dependencies first
    # (This allows better caching if you don't change your go.mod often.)
    COPY go.mod go.sum ./
    RUN go mod download
    
    # Copy the rest of the source code
    COPY . .
    
    # Build the Go binary
    RUN go build -o authserver
    
    # --------------------------------------------------
    # Final Stage
    # --------------------------------------------------
    FROM ubuntu:24.04
    
    # Set noninteractive mode for apt (just in case)
    ENV DEBIAN_FRONTEND=noninteractive
    
    # Install minimal dependencies (if necessary)
    RUN apt-get update && \
        apt-get install -y ca-certificates && \
        rm -rf /var/lib/apt/lists/*
    
    # Create a user (optional for security)
    RUN useradd -m -s /usr/sbin/nologin authuser
    
    WORKDIR /app
    
    # Copy the compiled binary from the builder stage
    COPY --from=builder /app/authserver /app/
    
    # Adjust permissions to run as non-root
    RUN chown authuser:authuser /app/authserver && chmod 755 /app/authserver
    
    # Switch to our new non-root user
    USER authuser
    
    # Expose port 8000
    EXPOSE 8000
    
    # Start the server
    CMD ["./authserver"]
    