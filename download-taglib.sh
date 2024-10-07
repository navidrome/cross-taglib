#!/bin/zsh

set -e

source .versions

rm -rf ./taglib
git clone https://github.com/taglib/taglib.git
cd taglib
git checkout v"$TAGLIB_VERSION"
test $(git rev-parse HEAD) = "$TAGLIB_SHA" || exit 1;
git submodule update --init
find . -name .git | xargs rm -rf