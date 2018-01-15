#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
LIVE_CERT_FOLDER="${LIVE_CERT_FOLDER:-/etc/letsencrypt/live}"
CERTBOT_EXTRA_OPTIONS="${CERTBOT_EXTRA_OPTIONS:-}"
CRONJOB="${CRONJOB:-true}"
GENERATE_TEMP_CERTIFICATE="${GENERATE_TEMP_CERTIFICATE:-false}"
PREFERRED_CHALLENGE="${PREFERRED_CHALLENGE:-http}"
CLOUDFLARE_EMAIL="${CLOUDFLARE_EMAIL:-}"
CLOUDFLARE_API_KEY="${CLOUDFLARE_API_KEY:-}"

# Log message
log(){
  echo "[$(date "+%Y-%m-%dT%H:%M:%S%z") - $(hostname)] ${*}"
}

# Install cron
run_cron(){
  # Make sure we update certificates daily (and remove the .sh for cron to run)
  ln -fs /entrypoint.sh /etc/periodic/daily/letsencrypt

  # Run cron daemon
  log 'Run daily tasks'
  exec crond -l 6 -f
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

# Create or renew certificates (using webroot)
# Certificates are separated by semi-colon (;)
# Domains on each certificate are separated by comma (,).
# Ex: 'DOMAINS=foo.com,www.foo.com;bar.com,www.bar.com'
update_certificates_webroot(){
  IFS=';' read -ra CERTS <<< "$DOMAINS"
  for DOMAINS in "${CERTS[@]}"; do
    log "Generating SSL certificates for ${DOMAINS} (using webroot)"
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
      "$CERTBOT_EXTRA_OPTIONS" || true
  done
}

# Create or renew certificates (using the dns-cloudflare plugin)
# Certificates are separated by semi-colon (;)
# Domains on each certificate are separated by comma (,).
# Ex: 'DOMAINS=foo.com,www.foo.com;bar.com,www.bar.com'
update_certificates_dns_cloudflare() {
  IFS=';' read -ra CERTS <<< "$DOMAINS"
  for DOMAINS in "${CERTS[@]}"; do
    log "Generating SSL certificates for ${DOMAINS} (using dns)"
    eval certbot certonly \
      --domains "$DOMAINS" \
      --email "$EMAIL" \
      --expand \
      --agree-tos \
      --rsa-key-size 4096 \
      --non-interactive \
      --text \
      --dns-cloudflare \
      --dns-cloudflare-credentials "$CLOUDFLARE_CREDENTIALS" \
      "$CERTBOT_EXTRA_OPTIONS" || true
  done
}

# The HTTP challenge logic
http_challenge() {
  if [[ "$GENERATE_TEMP_CERTIFICATE" == 'true' ]]; then
    generate_temp_certificate
  fi

  create_web_server 80 &
  wait_for_server localhost

  IFS=',;' read -ra SERVERS <<< "$DOMAINS"
  wait_for_server "${SERVERS[0]}"

  update_certificates_webroot
}

dns_challenge(){
  # Auto-detect challenges
  if ( [[ -n "${CLOUDFLARE_EMAIL}" ]] && [[ -n "${CLOUDFLARE_API_KEY}" ]] ) || \
     [[ -s /run/secrets/cloudflare_credentials.ini ]]
  then
    cloudflare_challenge
  fi
}

# The DNS challenge logic
cloudflare_challenge() {
  # Prepare credentials
  if [[ -n "${CLOUDFLARE_EMAIL}" ]] && [[ -n "${CLOUDFLARE_API_KEY}" ]]; then
    CLOUDFLARE_CREDENTIALS='/tmp/cloudflare_credentials.ini'
    echo "dns_cloudflare_email = ${CLOUDFLARE_EMAIL}" > "$CLOUDFLARE_CREDENTIALS"
    echo "dns_cloudflare_api_key = ${CLOUDFLARE_API_KEY}" >> "$CLOUDFLARE_CREDENTIALS"
  elif [[ -s /run/secrets/cloudflare_credentials.ini ]]; then
    CLOUDFLARE_CREDENTIALS='/run/secrets/cloudflare_credentials.ini'
  else
    log 'The required credentials for Cloudflare are missing!'
    exit 1
  fi

  chmod 600 "$CLOUDFLARE_CREDENTIALS"

  update_certificates_dns_cloudflare
}

main(){
  # Validate required environment variables.
  [[ -z "${DOMAINS+x}" ]] && MISSING="${MISSING} DOMAINS"
  [[ -z "${EMAIL+x}" ]] && MISSING="${MISSING} EMAIL"

  if [[ -n "${MISSING:-}" ]]; then
    log "Missing required environment variables: ${MISSING}"
    exit 1
  fi

  # Challenges
  case "$PREFERRED_CHALLENGE" in
    http)
      http_challenge
      ;;
    dns)
      dns_challenge
      ;;
    *)
      log "The '${PREFERRED_CHALLENGE}' authentication method is not supported yet!"; exit 1
      ;;
  esac

  if [[ "$CRONJOB" == 'true' ]]; then
    pgrep crond >/dev/null || run_cron
  fi
}

main "${@:-}"
