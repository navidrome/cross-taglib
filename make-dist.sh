#!/bin/bash

set -e

source .versions

cd dist

for f in *; do \
  echo "Packing $f"
  zip -r "taglib-$TAGLIB_VERSION-$RELEASE_VERSION-$f.zip" "$f"
done
