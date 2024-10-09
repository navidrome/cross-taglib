FROM --platform=$BUILDPLATFORM crazymax/osxcross:11.3 AS osxcross
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM debian:bookworm AS build
RUN apt-get update && apt-get install -y clang lld cmake
# copy xx scripts to your build stage
COPY --from=xx / /
# export TARGETPLATFORM (or other TARGET*)
ARG TARGETPLATFORM


RUN xx-apt install -y binutils gcc g++ libc6-dev zlib1g-dev

# Set working directory
WORKDIR /src

ARG TAGLIB_VERSION
ENV TABLIB_BUILD_OPTS="-DCMAKE_BUILD_TYPE=Release -DWITH_MP4=ON -DWITH_ASF=ON -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF"
COPY taglib /tmp/taglib

RUN  --mount=from=osxcross,target=/xx-sdk,src=/osxcross,rw \
    echo "Build static TagLib $TAGLIB_VERSION for $TARGETPLATFORM" && \
    cd /tmp/taglib && \
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