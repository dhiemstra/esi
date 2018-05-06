#!/bin/bash

set -e

VERSION="$1"

if [ -z "$VERSION" ]; then
  echo "Usage: ./release.sh VERSION"
  exit 1
fi

sed -i "s/VERSION = .*/VERSION = '${VERSION}'/" lib/eve_app/version.rb
bundle install

git commit -am "Release v${VERSION}"
git tag "v${VERSION}" -a -m "Release v${VERSION}"
git push origin master --follow-tags
