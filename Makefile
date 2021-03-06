TAGS ?= "sqlite"
LDFLAGS ?= "-X ipop.Debug=true -X ipop.Color=true"

CURL_BIN ?= curl
GO_BIN ?= go
LINT_BIN ?= gometalinter

export PATH := ./bin:$(PATH)

install: deps

deps:
	$(GO_BIN) get -tags ${TAGS} ./...
	$(GO_BIN) get -tags ${TAGS} github.com/gobuffalo/pop/soda
	$(CURL_BIN) -L https://git.io/vp6lP | sh
ifeq ($(GO111MODULE),on)
	$(GO_BIN) mod tidy
endif

test:
	rm -f .test.sqlite
	$(GO_BIN) test -tags ${TAGS} -ldflags ${LDFLAGS} ./...

ci-test:
	rm -f .test.sqlite
	$(GO_BIN) test -tags ${TAGS} -ldflags ${LDFLAGS} -race  -coverprofile=coverage.txt -covermode=atomic ./...

lint:
	$(LINT_BIN) --vendor ./... --deadline=1m --skip=internal

update:
	$(GO_BIN) get -u -tags ${TAGS}
ifeq ($(GO111MODULE),on)
	$(GO_BIN) mod tidy
endif
	make test
	make install
ifeq ($(GO111MODULE),on)
	$(GO_BIN) mod tidy
endif
