include .versions

build:
	docker build \
		--platform "linux/amd64,linux/arm64,linux/arm/v6,linux/arm/v7,linux/386,darwin/amd64,darwin/arm64" \
		--build-arg TAGLIB_VERSION=${TAGLIB_VERSION} \
		--build-arg TAGLIB_SHA=${TAGLIB_SHA} \
		--output "./dist" \
		--target "artifact" .
.PHONY: build

#		--platform "linux/amd64,linux/arm64,linux/arm/v6,linux/arm/v7,linux/386,darwin/arm64,darwin/amd64,windows/amd64,windows/386" \

dist: build
	./make-dist.sh
.PHONY: dist

update:
	./latest-version.sh > .versions
	git diff .versions
.PHONY: update

clean:
	rm -rf dist/*
.PHONY: clean
