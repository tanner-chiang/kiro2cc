# Build stage
FROM golang:1.23.3-alpine AS builder

# Set working directory
WORKDIR /app

# Copy go mod file
COPY go.mod ./

# Download dependencies (if any)
RUN go mod download

# Copy source code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o kiro2cc main.go

# Final stage
FROM alpine:latest

# Create a non-root user
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -D appuser

# Set working directory
WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/kiro2cc .

# Change ownership to appuser
RUN chown appuser:appuser /app/kiro2cc

# Switch to non-root user
USER appuser

# Expose the default server port
EXPOSE 8080

# Set the binary as entrypoint
ENTRYPOINT ["./kiro2cc"]

# Default command
CMD ["server"]