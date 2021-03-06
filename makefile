VERSION := $(shell grep -Eo '(v[0-9]+[\.][0-9]+[\.][0-9]+(-[a-zA-Z0-9]*)?)' internal/version/version.go)

.PHONY: build docker release

build:
	go fmt ./...
	CGO_ENABLED=1 go build -o bin/paygate .

docker:
	docker build -t moov/paygate:$(VERSION) -f Dockerfile .
	docker tag moov/paygate:$(VERSION) moov/paygate:latest

release: docker AUTHORS
	go vet ./...
	go test ./...
	git tag -f $(VERSION)

release-push:
#	echo "$DOCKER_PASSWORD" | docker login -u wadearnold --password-stdin
#	git push origin $(VERSION)
	docker push moov/paygate:$(VERSION)

# From https://github.com/genuinetools/img
.PHONY: AUTHORS
AUTHORS:
	@$(file >$@,# This file lists all individuals having contributed content to the repository.)
	@$(file >>$@,# For how it is generated, see `make AUTHORS`.)
	@echo "$(shell git log --format='\n%aN <%aE>' | LC_ALL=C.UTF-8 sort -uf)" >> $@
