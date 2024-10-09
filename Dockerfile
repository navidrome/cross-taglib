FROM --platform=$BUILDPLATFORM crazymax/osxcross:11.3-debian AS osxcross
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM debian:bookworm AS base
ARG TAGLIB_VERSION=2.0.2
ARG TAGLIB_SHA=e3de03501ff66221d1f1f971022b248d5b38ba06

RUN apt-get update && apt-get install -y clang lld cmake git
# copy xx scripts to your build stage
COPY --from=xx / /
# export TARGETPLATFORM (or other TARGET*)
ARG TARGETPLATFORM
# Set working directory

FROM --platform=$BUILDPLATFORM base AS source
RUN cd / && \
    git clone https://github.com/taglib/taglib.git taglib-src && \
    cd taglib-src && \
    git checkout v$TAGLIB_VERSION && \
    test `git rev-parse HEAD` = $TAGLIB_SHA || exit 1; \
    git submodule update --init && \
    find . -name .git | xargs rm -rf

FROM --platform=$BUILDPLATFORM base AS build
RUN xx-apt install -y binutils gcc g++ libc6-dev zlib1g-dev
ENV TABLIB_BUILD_OPTS="-DCMAKE_BUILD_TYPE=Release -DWITH_MP4=ON -DWITH_ASF=ON -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF"

COPY --from=source /taglib-src /taglib-src
RUN  --mount=from=osxcross,target=/xx-sdk,src=/osxcross/SDK,rw \
    echo "Build static TagLib $TAGLIB_VERSION for $TARGETPLATFORM" && \
    cd /taglib-src && \
    cmake $TAGLIB_BUILD_OPTS  \
        $(xx-clang --print-cmake-defines) \
        -DCMAKE_INSTALL_PREFIX=/taglib $TABLIB_BUILD_OPTS \
    && make install

# Verify if the artifact has been built for the correct platform
RUN mkdir -p /tmp/archive \
    && cd /tmp/archive \
    && ar -x /taglib/lib/libtag.a xmfile.cpp.o \
    && xx-verify xmfile.cpp.o

FROM scratch AS artifact
COPY --from=build /taglib /