#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
LIVE_CERT_FOLDER="${LIVE_CERT_FOLDER:-/etc/letsencrypt/live}"

# Log message
log(){
  echo "$(date): ${*}"
}

# Install cron
setup_cron(){
  # make sure we update certificates daily
  log 'Installing daily tasks'
  ln -fs /entrypoint.sh /etc/periodic/daily/
}

# Create a basic web server
create_web_server(){
  local port="${1:-80}"
  log "Creating http server port ${port}"
  ( mkdir -p /tmp/www && cd /tmp/www && python -m SimpleHTTPServer "${port}")
}

# Wait for specified server to be listening
wait_for_server(){
  local server="${1:-localhost}"
  local port="${2:-80}"
  while ! nc -z "$server" "$port"; do
    log "${server}:${port} not up yet, waiting..."
    sleep 1
  done
}

# Create a temporary certificate for HAProxy
generate_temp_certificate(){
  if [[ ! -s "${LIVE_CERT_FOLDER}/temporary/fullchain.pem" ]]; then
    log 'Generating temporary SSL certificate'
    mkdir -p "${LIVE_CERT_FOLDER}/temporary"
    openssl req -x509 -newkey rsa:1024 -keyout "${LIVE_CERT_FOLDER}/temporary/privkey.pem" -out "${LIVE_CERT_FOLDER}/temporary/fullchain.pem" -days 1 -nodes -subj '/CN=*/O=Temporary SSL Certificate/C=US'
  fi
}

update_certificates(){
  # Certificates are separated by semi-colon (;)
  # Domains on each certificate are separated by comma (,).
  # Ex: DOMAINS=foo.com,www.foo.com;bar.com,www.bar.com
  IFS=';' read -r -a CERTS <<< "$DOMAINS"

  # Create or renew certificates
  for DOMAINS in "${CERTS[@]}"; do
    log "Generating SSL certificates for ${DOMAINS}"
    certbot certonly \
      --domains "$DOMAINS" \
      --email "$EMAIL" \
      --expand \
      --agree-tos \
      --rsa-key-size 4096 \
      --non-interactive \
      --text \
      --webroot \
      --webroot-path /tmp/www \
      $OPTIONS || true
  done
}

main(){
  # Validate required environment variables.
  [[ -z "${DOMAINS+x}" ]] && MISSING="${MISSING} DOMAINS"
  [[ -z "${EMAIL+x}" ]] && MISSING="${MISSING} EMAIL"
  [[ -z "${LOAD_BALANCER_SERVICE_NAME+x}" ]] && MISSING="${MISSING} LOAD_BALANCER_SERVICE_NAME"

  if [[ -n "${MISSING:-}" ]]; then
    log "Missing required environment variables: ${MISSING}"
    exit 1
  fi

  generate_temp_certificate

  setup_cron
  create_web_server &

  log 'Waiting for service SimpleHTTPServer'
  wait_for_server localhost

  log "Waiting for service \"${LOAD_BALANCER_SERVICE_NAME}\""
  wait_for_server "$LOAD_BALANCER_SERVICE_NAME"

  log "Loadbalancer service \"${LOAD_BALANCER_SERVICE_NAME}\" is online"
  update_certificates &

  exec "${@:-}"
}

main "${@:-}"
