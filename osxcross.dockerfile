FROM --platform=$BUILDPLATFORM crazymax/osxcross:11.3-debian AS osxcross

FROM debian
COPY --from=osxcross /osxcross /osxcross