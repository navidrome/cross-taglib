FROM --platform=$BUILDPLATFORM crazymax/osxcross:14.5-debian AS osxcross
FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.5.0 AS xx

FROM --platform=$BUILDPLATFORM debian:bookworm-20240926-slim AS base
ARG TAGLIB_VERSION=2.0.2
ARG TAGLIB_SHA=e3de03501ff66221d1f1f971022b248d5b38ba06

# Install platform agnostic build dependencies
RUN apt-get update && apt-get install -y clang lld cmake git
COPY --from=xx / /

# Download TagLib source for specified version
RUN cd / && \
    git clone https://github.com/taglib/taglib.git taglib-src && \
    cd taglib-src && \
    git checkout v$TAGLIB_VERSION && \
    test `git rev-parse HEAD` = $TAGLIB_SHA || exit 1; \
    git submodule update --init && \
    find . -name .git | xargs rm -rf

FROM --platform=$BUILDPLATFORM base AS build
# Install build dependencies for the target platform
ARG TARGETPLATFORM
RUN xx-apt install -y binutils gcc g++ libc6-dev zlib1g-dev

# Build TagLib for the target platform
RUN --mount=from=osxcross,target=/osxcross,src=/osxcross,ro <<EOT
    echo "Build static TagLib $TAGLIB_VERSION for $TARGETPLATFORM" && \

    TAGLIB_BUILD_OPTS="-DCMAKE_BUILD_TYPE=Release -DWITH_MP4=ON -DWITH_ASF=ON -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF"
    case "$(xx-info os)" in
        darwin)
            TAGLIB_BUILD_OPTS="$TAGLIB_BUILD_OPTS -DCMAKE_SYSTEM_NAME=Darwin"
            TAGLIB_BUILD_OPTS="$TAGLIB_BUILD_OPTS $(xx-clang --print-cmake-defines)"
            TAGLIB_BUILD_OPTS="$TAGLIB_BUILD_OPTS -DCMAKE_AR=/osxcross/bin/x86_64-apple-darwin20.4-ar"
            TAGLIB_BUILD_OPTS="$TAGLIB_BUILD_OPTS -DCMAKE_RANLIB=/osxcross/bin/x86_64-apple-darwin20.4-ranlib"
            mkdir -p /xx-sdk && ln -s /osxcross/SDK/MacOSX11* /xx-sdk/MacOSX11.1.sdk
            ;;
        windows)
            TAGLIB_BUILD_OPTS="$TAGLIB_BUILD_OPTS -DCMAKE_SYSTEM_NAME=Windows"
            ;;
    esac

    cd /taglib-src
    cmake   \
        -DCMAKE_INSTALL_PREFIX=/taglib \
        -DCMAKE_CROSSCOMPILING=TRUE \
        -DCMAKE_C_COMPILER=$(xx-info)-gcc \
        -DCMAKE_CXX_COMPILER=$(xx-info)-g++ \
        ${TAGLIB_BUILD_OPTS}
    make install
EOT

# Verify if the library was built for the correct platform. Skip platforms not supported by xx-verify.
RUN bash -c "[[ $(xx-info os) =~ (windows|freebsd) ]]" || \
    (mkdir -p /tmp/archive \
    && cd /tmp/archive \
    && ar -x /taglib/lib/libtag.a \
    && xx-verify xmfile.cpp.*)

FROM scratch AS artifact
COPY --from=build /taglib /