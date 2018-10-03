#!/usr/bin/env bash
# Docker script
# https://docs.docker.com/docker-cloud/builds/advanced/

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# DEBUG
[ -z "${DEBUG:-}" ] || set -x

# VARs
GIT_TAG="$(git describe --always --tags)"
BUILD_PATH="${BUILD_PATH:-.}"
DOCKERFILE_PATH="${DOCKERFILE_PATH:-Dockerfile}"
DOCKER_USERNAME="${DOCKER_USERNAME:-}"
DOCKER_PASSWORD="${DOCKER_PASSWORD:-}"
DOCKER_REPO="${DOCKER_REPO:-}"
DOCKER_TAG="${DOCKER_TAG:-${GIT_TAG}}"
IMAGE_NAME="${IMAGE_NAME:-${DOCKER_REPO}:${DOCKER_TAG}}"
MICROBADGER_WEBHOOK="${MICROBADGER_WEBHOOK:-}"

# Generate semantic version style tags
generate_semantic_version(){
  # If tag matches semantic version
  if [[ "$GIT_TAG" != v* ]]; then
    echo "Version (${GIT_TAG}) does not match semantic version; Skipping..."
    return
  fi

  echo "Using version ${GIT_TAG}"

  # Break the version into components
  semver="${GIT_TAG#v}" # Remove the 'v' prefix
  semver="${semver%%-*}" # Remove the commit number
  IFS="." read -r -a semver <<< "$semver" # Create an array with version numbers

  export major="${semver[0]}"
  export minor="${semver[1]}"
  export patch="${semver[2]}"
}

# Deepen repository history
# When Docker Cloud pulls a branch from a source code repository, it performs a shallow clone (only the tip of the specified branch). This has the advantage of minimizing the amount of data transfer necessary from the repository and speeding up the build because it pulls only the minimal code necessary.
# Because of this, if you need to perform a custom action that relies on a different branch (such as a post_push hook), you won’t be able checkout that branch, unless you do one of the following:
#    $ git pull --depth=50
#    $ git fetch --unshallow origin
deepen_git_repo(){
  if [[ "$(git rev-parse --is-shallow-repository)" == 'true' ]]; then
    echo 'Deepen repository history'
    git fetch --unshallow origin
  fi
}

# Build the image with the specified arguments
build_image(){
  echo 'Build the image with the specified arguments'
  deepen_git_repo
  (
  cd "$BUILD_PATH"
  docker build \
    --build-arg VERSION="$GIT_TAG" \
    --build-arg VCS_URL="$(git config --get remote.origin.url)" \
    --build-arg VCS_REF="$(git rev-parse --short HEAD)" \
    --build-arg BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --file "$DOCKERFILE_PATH" \
    --tag "$IMAGE_NAME" \
    .
  )
}

# Push
push_image(){
  echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin
  echo "Pushing ${IMAGE_NAME}"
  docker push "${IMAGE_NAME}"
  echo "Pushing 'latest'"
  docker tag "$IMAGE_NAME" "${DOCKER_REPO}:latest"
  docker push "${DOCKER_REPO}:latest"
}

# Tag image
# This creates semantic version style tags from latest (built just once).
# An alternative approach would be to use build rules (however, this triggers multiple builds for each tag, which is inefficient).
#
#     Type    Name                                  Location    Tag
#     Tag     /^v([0-9]+)\.([0-9]+)\.([0-9]+)$/     /           {\1}.{\2}.{\3}
#     Tag     /^v([0-9]+)\.([0-9]+)\.([0-9]+)$/     /           {\1}.{\2}
#     Tag     /^v([0-9]+)\.([0-9]+)\.([0-9]+)$/     /           {\1}
tag_image(){
  generate_semantic_version
  push_image

  for version in "${major}.${minor}.${patch}" "${major}.${minor}" "${major}"; do
    echo "Pushing version (${DOCKER_REPO}:${version})"
    docker tag "$IMAGE_NAME" "${DOCKER_REPO}:${version}"
    docker push "${DOCKER_REPO}:${version}"
  done
}

# Notify
notify_microbadger(){
  # shellcheck disable=1090
  . "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/.microbadger"

  local token="${MICROBADGER_TOKENS[${DOCKER_REPO}]:-}"
  local url="https://hooks.microbadger.com/images/${DOCKER_REPO}/${token}"

  if [[ -n "$token" ]]; then
    echo "Notify MicroBadger: $(curl -sX POST "$url")"
  fi
}

# Tests
test_image(){
  export PATH="$PATH":~/bin
  # TODO dgoss run ...
}

# Logic
main(){
  export cmd="${1:-}"; shift || true
  case "$cmd" in
    build)
      build_image
      ;;
    push)
      push_image
      ;;
    tag)
      tag_image
      ;;
    notify)
      notify_microbadger
      ;;
    test)
      test_image
      ;;
    *)
      echo "'${cmd}' command is not implemented"
      ;;
  esac
}

# Run
main "${@:-}"
