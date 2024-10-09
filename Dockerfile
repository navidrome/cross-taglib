FROM --platform=$BUILDPLATFORM crazymax/osxcross:11.3-debian AS osxcross
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM debian:bookworm AS base
ARG TAGLIB_VERSION=2.0.2
ARG TAGLIB_SHA=e3de03501ff66221d1f1f971022b248d5b38ba06

# Install build dependencies
RUN apt-get update && apt-get install -y clang lld cmake git
# copy xx scripts to your build stage
COPY --from=xx / /
COPY bin/* /usr/local/bin

FROM --platform=$BUILDPLATFORM base AS source
RUN cd / && \
    git clone https://github.com/taglib/taglib.git taglib-src && \
    cd taglib-src && \
    git checkout v$TAGLIB_VERSION && \
    test `git rev-parse HEAD` = $TAGLIB_SHA || exit 1; \
    git submodule update --init && \
    find . -name .git | xargs rm -rf

FROM --platform=$BUILDPLATFORM base AS build
ARG TARGETPLATFORM
RUN xx-apt install -y binutils gcc g++ libc6-dev zlib1g-dev
ENV TABLIB_BUILD_OPTS="-DCMAKE_BUILD_TYPE=Release -DWITH_MP4=ON -DWITH_ASF=ON -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF"

COPY --from=source /taglib-src /taglib-src
RUN --mount=from=osxcross,target=/osxcross,src=/osxcross,ro \
    echo "Build static TagLib $TAGLIB_VERSION for $TARGETPLATFORM" && \
    ln -s /osxcross/SDK /xx-sdk && \
    cd /taglib-src && \
    cmake $TAGLIB_BUILD_OPTS  \
        -DCMAKE_INSTALL_PREFIX=/taglib \
        -DCMAKE_CROSSCOMPILING=TRUE \
        -DCMAKE_C_COMPILER=$(xx-info)-gcc \
        -DCMAKE_CXX_COMPILER=$(xx-info)-g++ \
        $(xx-cmake-extras) \
    && make install

# Verify if the library was built for the correct platform. Skip platforms not supported by xx-verify.
RUN bash -c "[[ $(xx-info os) =~ (windows|freebsd) ]]" || \
    (mkdir -p /tmp/archive \
    && cd /tmp/archive \
    && ar -x /taglib/lib/libtag.a \
    && xx-verify xmfile.cpp.*)

FROM scratch AS artifact
COPY --from=build /taglib /