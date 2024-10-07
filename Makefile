include .versions

build:
	if [ ! taglib/README.md ]; then \
		./download-taglib.sh; \
	fi
	docker build \
		--platform "linux/amd64,linux/arm64,linux/arm/v7,linux/386" \
		--build-arg TAGLIB_VERSION=${TAGLIB_VERSION} \
		--build-arg TAGLIB_SHA=${TAGLIB_SHA} \
		--output "./dist" \
		--target "artifact" .
.PHONY: build

dist: build
	./make-dist.sh
.PHONY: dist

download:
	./download-taglib.sh
.PHONY: download

update:
	./latest-version.sh > .versions
	git diff .versions
.PHONY: update

clean:
	rm -rf dist/* taglib
.PHONY: clean
