FROM golang:1.26.1-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o api ./cmd/api

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/api .
COPY migrations /app/migrations
COPY start.sh /app/start.sh

# Install golang-migrate
RUN wget -qO- https://github.com/golang-migrate/migrate/releases/download/v4.17.0/migrate.linux-amd64.tar.gz | tar xvz \
    && mv migrate /usr/local/bin/migrate

RUN chmod +x /app/start.sh

EXPOSE 8080
CMD ["/bin/sh", "/app/start.sh"]
