#FROM docker.elastic.co/beats-dev/golang-crossbuild:1.23.2-arm
FROM golang:bullseye AS build

# Download TagLib source
ARG TAGLIB_VERSION
ARG TAGLIB_SHA
ENV TABLIB_BUILD_OPTS=-DCMAKE_BUILD_TYPE=Release -DWITH_MP4=ON -DWITH_ASF=ON -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y automake autogen pkg-config \
    libtool libxml2-dev uuid-dev libssl-dev bash \
    patch cmake make tar xz-utils bzip2 gzip zlib1g-dev sed cpio \
    --no-install-recommends \
    || exit 1

COPY taglib /tmp/taglib

ARG TARGETPLATFORM
RUN echo "Build static TagLib $TAGLIB_VERSION for $TARGETPLATFORM" && \
    cd /tmp/taglib && \
    cmake -DCMAKE_INSTALL_PREFIX=/out $TABLIB_BUILD_OPTS && \
    make install

FROM scratch AS artifact
COPY --from=build /out /
