#!/bin/bash

set -e

source .version
RELEASE_VERSION=$1

cd dist

# Zip all folders in the dist directory
for f in *; do
  if [ -d "$f" ]; then
    echo "Zipping $f";
    zip -rq "taglib-$TAGLIB_VERSION-$RELEASE_VERSION-$f.zip" "$f";
  fi;
done
