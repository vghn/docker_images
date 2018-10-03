#!/usr/bin/env bash
# Release script
# https://docs.docker.com/docker-cloud/builds/advanced/

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# DEBUG
[ -z "${DEBUG:-}" ] || set -x

# VARs
GIT_TAG="$(git describe --always --tags)"
WRITE_CHANGELOG="${WRITE_CHANGELOG:-false}"
BUG_LABELS="${BUG_LABELS:-bug}"
ENHANCEMENT_LABELS="${ENHANCEMENT_LABELS:-enhancement}"
GCG_CMD="github_changelog_generator --bug-labels ${BUG_LABELS} --enhancement-labels ${ENHANCEMENT_LABELS}"

# Check if the repository is clean
git_clean_repo(){
  # Check if there are untracked files
  if [[ ! -z $(git ls-files --others --exclude-standard) ]]; then
    echo 'ERROR: There are untracked files.'
    return 1
  fi

  # Check if there are uncommitted changes
  if ! git diff --quiet HEAD; then
    echo 'ERROR: Commit your changes first'
    return 1
  fi
}

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

  export MAJOR="${semver[0]}"
  export MINOR="${semver[1]}"
  export PATCH="${semver[2]}"
}

# Increment Semantic Version
increment(){
  generate_semantic_version

  case "${1:-patch}" in
    major)
      export MAJOR=$((MAJOR+1))
      ;;
    minor)
      export MINOR=$((MINOR+1))
      ;;
    patch)
      export PATCH=$((PATCH+1))
      ;;
    *)
      export PATCH=$((PATCH+1))
      ;;
  esac
}

# logic
main(){
  case "${1:-patch}" in
    major)
      increment major
      ;;
    minor)
      increment minor
      ;;
    patch)
      increment patch
      ;;
    unreleased)
      eval "$GCG_CMD --unreleased"
      exit
      ;;
    *)
      increment patch
      ;;
  esac

  RELEASE="v${MAJOR}.${MINOR}.${PATCH}"

  git_clean_repo

  if [[ "$WRITE_CHANGELOG" == 'true' ]]; then
    eval "$GCG_CMD --future-release ${RELEASE}"

    if git diff --quiet HEAD; then
      echo 'CHANGELOG has not changed. Skipping...'
    else
      echo 'Commit CHANGELOG'
      git commit --gpg-sign --message "Update change log for ${RELEASE}" CHANGELOG.md
    fi

    echo "Tag  ${RELEASE}"
    git tag --sign "${RELEASE}" --message "Release ${RELEASE}"
    git push --follow-tags
  fi
}

# Run
main "${@:-}"
