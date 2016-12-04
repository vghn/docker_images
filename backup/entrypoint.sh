#!/usr/bin/env bash

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
AWS_S3_BUCKET="${AWS_S3_BUCKET:-backup_$(date +%s | sha256sum | base64 | head -c 16 ; echo)}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
GPG_RECIPIENT="${GPG_RECIPIENT:-}"
BACKUP_PATHS="${BACKUP_PATHS:-/backup}"
BACKUP_RESTORE="${BACKUP_RESTORE:-false}"
NOW=$(date +"%Y-%m-%d_%H-%M-%S")
TMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'tmp')
BACKUP_FILE="${NOW}.tar.xz"
BACKUP_FILE_ENCRYPTED="${BACKUP_FILE}.gpg"
RESTORE_FILE=
RESTORE_FILE_DECRYPTED="decrypted.tar.xz"
CRON_TIME="${CRON_TIME:-8 */8 * * *}"

# Log message
log(){
  echo "$(date): ${*}"
}

# Tar GZ everything
create_archive(){
  log "Create ${BACKUP_FILE}"
  tar cJf "$BACKUP_FILE" "$BACKUP_PATHS"
}

# Import public GPG key
import_gpg_keys(){
  if [[ -d /keys ]]; then
    log "Import all keys in '/keys' folder"
    gpg --batch --import /keys/*
  fi
}

# Encrypt the backup tar.gz
encrypt_archive(){
  log "Encrypt ${BACKUP_FILE_ENCRYPTED}"
  gpg --trust-model always --output "$BACKUP_FILE_ENCRYPTED" --batch --encrypt --recipient "$GPG_RECIPIENT" "$BACKUP_FILE"
}

# Create bucket, if it doesn't already exist
ensure_s3_bucket(){
  if [[ -s /var/run/backup_bucket_name ]]; then
    # Persist bucket name
    export AWS_S3_BUCKET; AWS_S3_BUCKET="$(cat /var/run/backup_bucket_name)"
    log "Using '${AWS_S3_BUCKET}' bucket"
  elif ! aws s3 ls "$AWS_S3_BUCKET" >/dev/null 2>&1; then
    log "Create '${AWS_S3_BUCKET}' bucket"
    aws s3 mb "s3://${AWS_S3_BUCKET}"
    echo "$AWS_S3_BUCKET" > /var/run/backup_bucket_name
  fi
}

# Upload archive to AWS S3
upload_archive(){
  # Copy to AWS S3
  aws s3 cp "$BACKUP_FILE_ENCRYPTED" \
    "s3://${AWS_S3_BUCKET}/${BACKUP_PREFIX}/${BACKUP_FILE_ENCRYPTED}"
}

# Backup logic
backup_archive(){
  export BACKUP_PREFIX=${1:-hourly}

  ensure_s3_bucket
  create_archive
  if [[ -n "$GPG_RECIPIENT" ]]; then
    encrypt_archive
  fi
  upload_archive
}

# List the latest S3 archive
latest_s3_archive(){
  if ! aws s3api list-objects \
    --bucket "$AWS_S3_BUCKET" \
    --query 'reverse(sort_by(Contents, &LastModified))[0].Key' \
    --output text
  then
    echo 'Could not retrieve the last S3 object'; exit 1
  fi
}

# Download the latest archive from S3
download_s3_archive(){
  RESTORE_FILE=$(latest_s3_archive)
  aws s3 cp "s3://${AWS_S3_BUCKET}/${RESTORE_FILE}" "$RESTORE_FILE"
}

# Decrypt archive
decrypt_archive(){
  log "Decrypt ${RESTORE_FILE}"
  export GPG_TTY=/dev/console
  gpg --batch --output "$RESTORE_FILE_DECRYPTED" --decrypt "$RESTORE_FILE"
}

# Extract the latest archive
extract_archive(){
  log "Extract '${RESTORE_FILE_DECRYPTED}' to '/restore'"
  mkdir -p /restore
  tar xJf "$RESTORE_FILE_DECRYPTED" --directory /restore
}

# Remove archives
clean_up(){
  log  'Remove working files'
  rm -r "$TMPDIR"
}

# Trap exit
bye(){
  log 'Exit detected; trying to clean up'
  clean_up; exit "${1:-0}"
}

main(){
    # Trap exit
  trap 'bye $?' HUP INT QUIT TERM

  # Set working directory
  cd "$TMPDIR" || exit

  # Parse CLI
  cmd="${1:-once}"
  case "$cmd" in
    once)
      import_gpg_keys
      ensure_s3_bucket
      backup_archive
      ;;
    cron)
      import_gpg_keys
      ensure_s3_bucket

      log 'Initial backup'
      backup_archive 'hourly'

      cat > /etc/crontabs/root <<CRON
${CRON_TIME} /entrypoint.sh hourly >> /backup.log 2>&1
2 2 * * * /entrypoint.sh daily >> /backup.log 2>&1
3 3 * * 6 /entrypoint.sh weekly >> /backup.log 2>&1
5 5 1 * * /entrypoint.sh monthly >> /backup.log 2>&1
CRON
      log "Run backups as a cronjob for ${CRON_TIME}"
      exec crond -l 2 -f
      ;;
    hourly)
      backup_archive 'hourly'
      ;;
    daily)
      backup_archive 'daily'
      ;;
    weekly)
      backup_archive 'weekly'
      ;;
    monthly)
      backup_archive 'monthly'
      ;;
    restore)
      import_gpg_keys
      download_s3_archive
      decrypt_archive
      extract_archive
      ;;
    *)
      log "Unknown command: ${cmd}"; exit 1
      ;;
  esac

  # Clean-up
  clean_up
}

main "${@:-}"
