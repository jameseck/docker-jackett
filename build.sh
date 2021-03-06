#!/bin/sh
set -e

if [ "$1" == "--check" ] || [ "$1" == "-c" ]; then
  CHECKONLY=true
fi

# Latest release
URL=$(curl -s https://api.github.com/repos/Jackett/Jackett/releases | jq -r "[ .[] | .assets[] | select(.name | test(\"Jackett.Binaries.LinuxAMDx64.tar.gz\")) ] | first | .browser_download_url")

VERSION=$(echo $URL | cut -d\/ -f8)

git pull > /dev/null 2>&1
DOCKERFILE_VERSION=$(grep "^ARG JACKETT_VERSION=" Dockerfile | cut -f2 -d\=)

if [ "${VERSION}" != "${DOCKERFILE_VERSION}" ]; then
  if [ "${CHECKONLY}" == "true" ]; then
    echo "There is a new version available"
    echo "Current version: ${DOCKERFILE_VERSION}"
    echo "Available version: ${VERSION}"
    exit 0
  fi

  echo "Updating Dockerfile with version ${VERSION}"
  sed -i -e "s/^\(ARG JACKETT_VERSION=\).*$/\1${VERSION}/g" \
         -e "s|^\(ARG JACKETT_URL=\).*$|\1${URL}|g" Dockerfile
  git add Dockerfile
  git commit -m "Bumping Jackett version to ${VERSION}"
  git push
  make minor-release
  exit -1
else
  make build
  make push
  echo "No change"
fi

# exit codes:
# 0 - no action
# -1 - new build pushed
# rest - errors
