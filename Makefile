include .version

RELEASE_VERSION ?= 0
PLATFORMS ?= linux/amd64,linux/arm64,linux/arm/v5,linux/arm/v6,linux/arm/v7,linux/386,darwin/amd64,darwin/arm64,windows/amd64,windows/386

build:
	docker build \
		--platform $(PLATFORMS) \
		--build-arg TAGLIB_VERSION=${TAGLIB_VERSION} \
		--build-arg TAGLIB_SHA=${TAGLIB_SHA} \
		--build-arg RELEASE_VERSION=${RELEASE_VERSION} \
		--output "./dist" \
		--target "artifact" .
.PHONY: build

dist: build
	./make-dist.sh ${RELEASE_VERSION}
.PHONY: dist

update:
	./latest-version.sh > .version
	git diff .version
.PHONY: update

clean:
	rm -rf dist/*
.PHONY: clean
