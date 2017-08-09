#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
LIVE_CERT_FOLDER="${LIVE_CERT_FOLDER:-/etc/letsencrypt/live}"
OPTIONS="${OPTIONS:-}"

# Log message
log(){
  echo "[$(date "+%Y-%m-%dT%H:%M:%S%z") - $(hostname)] ${*}"
}

# Trap exit
bye(){
  log 'Exit detected; trying to clean up'
  clean_up; exit "${1:-0}"
}

# Install cron
setup_cron(){
  # make sure we update certificates daily
  log 'Installing daily tasks'
  ln -fs /entrypoint.sh /etc/periodic/daily/
}

# Create a basic web server, unless it is already started
create_web_server(){
  local port="${1:-80}"
  if ! nc -z 127.0.0.1 "$port"; then
    log 'Creating a simple HTTP server'
    ( mkdir -p /tmp/www && cd /tmp/www && python -m SimpleHTTPServer "${port}" )
  fi
}

# Wait for specified server to be listening on the specified port
wait_for_server(){
  local server="${1:-localhost}"
  local port="${2:-80}"
  while ! nc -z "$server" "$port"; do
    log "${server}:${port} not up yet, waiting..."
    sleep 5
  done
}

# Create a temporary certificate so that the webserver can start
generate_temp_certificate(){
  if [[ ! -s "${LIVE_CERT_FOLDER}/temporary/fullchain.pem" ]]; then
    log 'Generating temporary SSL certificate'
    mkdir -p "${LIVE_CERT_FOLDER}/temporary"
    openssl req -x509 \
      -newkey rsa:1024 \
      -keyout "${LIVE_CERT_FOLDER}/temporary/privkey.pem" \
      -out "${LIVE_CERT_FOLDER}/temporary/fullchain.pem" \
      -days 1 \
      -nodes \
      -subj '/CN=*/O=Temporary SSL Certificate/C=US'
  fi
}

# Create or renew certificates
# Certificates are separated by semi-colon (;)
# Domains on each certificate are separated by comma (,).
# Ex: 'DOMAINS=foo.com,www.foo.com;bar.com,www.bar.com'
update_certificates(){
  IFS=';' read -r -a CERTS <<< "$DOMAINS"
  for DOMAINS in "${CERTS[@]}"; do
    log "Generating SSL certificates for ${DOMAINS}"
    eval certbot certonly \
      --domains "$DOMAINS" \
      --email "$EMAIL" \
      --expand \
      --agree-tos \
      --rsa-key-size 4096 \
      --non-interactive \
      --text \
      --webroot \
      --webroot-path /tmp/www \
      "$OPTIONS" || true
  done
}

main(){
  # Trap exit
  trap 'EXCODE=$?; bye; trap - EXIT; echo $EXCODE' EXIT HUP INT QUIT PIPE TERM

  # Validate required environment variables.
  [[ -z "${DOMAINS+x}" ]] && MISSING="${MISSING} DOMAINS"
  [[ -z "${EMAIL+x}" ]] && MISSING="${MISSING} EMAIL"

  if [[ -n "${MISSING:-}" ]]; then
    log "Missing required environment variables: ${MISSING}"
    exit 1
  fi

  generate_temp_certificate

  setup_cron
  
  create_web_server &

  wait_for_server localhost

  IFS=',;' read -r -a SERVERS <<< "$DOMAINS"
  wait_for_server "${SERVERS[0]}"

  update_certificates &

  exec "${@:-}"
}

main "${@:-}"
