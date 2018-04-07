#!/bin/sh
set -e

# Latest release
URL=$(curl -s https://api.github.com/repos/Jackett/Jackett/releases | jq -r "[ .[] | .assets[] | select(.name | test(\"Jackett.Binaries.Mono.tar.gz\")) ] | first | .browser_download_url")

VERSION=$(echo $URL | cut -d\/ -f8)

git pull > /dev/null 2>&1
DOCKERFILE_VERSION=$(grep "^ARG JACKETT_VERSION=" Dockerfile | cut -f2 -d\=)

if [ "${VERSION}" != "${DOCKERFILE_VERSION}" ]; then
  echo "Updating Dockerfile with version ${VERSION}"
  sed -i -e "s/^\(ARG JACKETT_VERSION=\).*$/\1${VERSION}/g" \
         -e "s|^\(ARG JACKETT_URL=\).*$|\1${URL}|g" Dockerfile
  git add Dockerfile
  git commit -m "Bumping Jackett version to ${VERSION}"
  git push
  make minor-release
  exit -1
else
  echo "No change"
fi

# exit codes:
# 0 - no action
# -1 - new build pushed
# rest - errors
