# syntax=docker/dockerfile:1

## ── builder stage ─────────────────────────────────────────────────────────────
FROM golang:1.24-alpine AS builder

RUN apk add --no-cache git ca-certificates

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o scribes ./cmd/server

## ── runtime stage ─────────────────────────────────────────────────────────────
FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/scribes /scribes
COPY --from=builder /app/migrations /migrations

EXPOSE 8080

ENTRYPOINT ["/scribes"]
