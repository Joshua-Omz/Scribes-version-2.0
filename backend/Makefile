.PHONY: dev migrate-up migrate-down generate test

dev:
	docker-compose up --build

migrate-up:
	docker run --rm -v ${PWD}/migrations:/migrations --network host migrate/migrate -path=/migrations/ -database postgres://scribes:password@localhost:5433/scribes_db?sslmode=disable up

migrate-down:
	docker run --rm -v ${PWD}/migrations:/migrations --network host migrate/migrate -path=/migrations/ -database postgres://scribes:password@localhost:5433/scribes_db?sslmode=disable down -all

generate:
	docker run --rm -v ${PWD}:/src -w /src kjconroy/sqlc generate

test:
	go test ./...
