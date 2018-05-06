#!/bin/bash

set -e

VERSION="$1"
VERSIONFILE="./lib/eve_app/version.rb"

if [ -z "$VERSION" ]; then
  echo "Usage: ./release.sh VERSION"
  exit 1
fi

if ! grep -q $VERSION "$VERSIONFILE"; then
  echo "VERSION is not properly set in '${VERSIONFILE}'"
  echo "Changing it for you.."
  sed -i "s/VERSION = .*/VERSION = '${VERSION}'/" "$VERSIONFILE"
fi

git commit -am "Release v${VERSION}"
git tag "v${VERSION}" -a -m "Release v${VERSION}"
git push origin master --follow-tags
