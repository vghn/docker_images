#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
CERT_FOLDER="${CERT_FOLDER:-/certs}"
LIVE_CERT_FOLDER="${LIVE_CERT_FOLDER:-/etc/letsencrypt/live}"
# Debounce for 10 seconds, which we assume is enough time to create or renew
# all certifies and avoid multiple restarts.
IGNORE_SECS=10

# Log message
log(){
  echo "$(date): ${*}"
}

# Make sure the certificate folder is created
ensure_cert_folders(){
  for DIR in "$CERT_FOLDER" "$LIVE_CERT_FOLDER"; do
    if [[ ! -d "$DIR" ]]; then
      log "Creating ${DIR}"
      mkdir -p "$DIR"
    fi
  done
}

# Abort, if already running.
check_inotify(){
  if pgrep -f inotifywait > /dev/null; then
    log "Already watching directory: ${LIVE_CERT_FOLDER}"; exit 1
  fi
}

# Install combined certificates compatible with HAproxy.
generate_haproxy_certificates(){
  log 'Waiting for the live certificates'
  until ls -A "$LIVE_CERT_FOLDER" >/dev/null 2>&1; do sleep 5; done

  # Certificate index
  COUNT=0

  # Generate certificates
  for DIR in "$LIVE_CERT_FOLDER"/*; do
    log "Waiting for certificates for ${DIR}"
    until grep -q '^-----BEGIN PRIVATE KEY-----.*' "${DIR}/privkey.pem"; do sleep 5; done
    until grep -q '^-----BEGIN CERTIFICATE-----.*' "${DIR}/fullchain.pem"; do sleep 5; done

    # HAProxy sorts through certificates in alphabetical order, so we can keep
    # the temporary self signed certificate if it is the last in list.
    if [[ "$DIR" =~ /temporary ]]; then PREFIX='xcert'; else PREFIX='cert'; fi

    log "Combining certificates for ${DIR}"
    cat "${DIR}/privkey.pem" "${DIR}/fullchain.pem" > "${CERT_FOLDER}/${PREFIX}${COUNT}.pem"
    (( COUNT += 1 ))
  done
}

# Watch the certificates directory.
# When changes are detected, reload HAproxy.
watch_certificates_folder(){
  if [[ -z ${LIVE_CERT_FOLDER:-} ]]; then return; fi

  ensure_cert_folders
  check_inotify

  IGNORE_UNTIL="$(date +%s)"

  log "Watching directory ${LIVE_CERT_FOLDER} for changes"
  inotifywait \
    --event create \
    --event delete \
    --event modify \
    --event move \
    --format "%e %w%f" \
    --monitor \
    --quiet \
    --recursive \
    "$LIVE_CERT_FOLDER" |
  while read -r CHANGED
  do
    log "$CHANGED"
    NOW="$(date +%s)"
    if (( NOW > IGNORE_UNTIL )); then
      (( IGNORE_UNTIL = NOW + IGNORE_SECS ))
      ( sleep $IGNORE_SECS && generate_haproxy_certificates && /reload.sh ) &
    fi
  done
}

main(){
  generate_haproxy_certificates
  watch_certificates_folder &
  exec "${@:-}"
}

main "${@:-}"
