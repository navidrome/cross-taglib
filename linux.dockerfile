# Use a multi-arch base image
FROM --platform=$TARGETPLATFORM alpine:3.20.3 AS builder

# Install build dependencies
RUN apk add --no-cache \
    cmake \
    g++ \
    make \
    utfcpp \
    zlib-dev

# Set working directory
WORKDIR /src

# Download and extract TagLib source
RUN wget https://taglib.org/releases/taglib-2.0.2.tar.gz \
    && tar -xzf taglib-2.0.2.tar.gz \
    && cd taglib-2.0.2

# Build TagLib
RUN cd taglib-2.0.2 && cmake  \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
    && make install

# Create a minimal runtime image
FROM --platform=$TARGETPLATFORM alpine:3.14

# Copy built TagLib libraries from builder
COPY --from=builder /usr/local/lib/libtag.so* /usr/local/lib/
COPY --from=builder /usr/local/include/taglib /usr/local/include/taglib

# Set library path
ENV LD_LIBRARY_PATH=/usr/local/lib

# Verify installation
RUN ls -l /usr/local/lib/libtag.so* && \
    ls -l /usr/local/include/taglib

# Set entrypoint to show TagLib version
ENTRYPOINT ["sh", "-c", "readelf -d /usr/local/lib/libtag.so | grep SONAME"]