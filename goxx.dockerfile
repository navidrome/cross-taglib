FROM --platform=$BUILDPLATFORM crazymax/osxcross:11.3 AS osxcross
FROM --platform=$BUILDPLATFORM crazymax/goxx:1.23 AS build
ENV CGO_ENABLED=1
RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt/lists \
    goxx-apt-get install -y binutils gcc g++ pkg-config cmake zlib1g-dev --no-install-recommends \
    || exit 1

COPY bin/* /usr/local/bin
COPY taglib /tmp/taglib

ARG TARGETPLATFORM
ARG TAGLIB_VERSION
ENV TABLIB_BUILD_OPTS="-DCMAKE_BUILD_TYPE=Release -DWITH_MP4=ON -DWITH_ASF=ON -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF"
#COPY --from=osxcross /osxcross /osxcross
#ENV PATH=/usr/local/bin:$PATH

RUN  --mount=from=osxcross,target=/osxcross,src=/osxcross,rw \
    echo "Build static TagLib $TAGLIB_VERSION for $TARGETPLATFORM" && \
    cd /tmp/taglib && \
    goxx-cmake  \
        -DCMAKE_INSTALL_PREFIX=/taglib $TABLIB_BUILD_OPTS && \
    make install

FROM scratch AS artifact
COPY --from=build /taglib /

#export TARGETPLATFORM=linux/amd64
#export CGO_ENABLED=1
#goxx-apt-get install -y binutils gcc g++ cmake cmake-data --no-install-recommends
#goxx-apt-get install -y pkg-config cmake zlib1g-dev --no-install-recommends