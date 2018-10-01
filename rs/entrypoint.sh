#!/usr/bin/env bash
# Entry Point
# @author Vlad Ghinea

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# VARs
CA_CERT="${CA_CERT:-/etc/ssl/certs/ca-cert.pem}"
SERVER_KEY="${SERVER_KEY:-/etc/ssl/certs/server-key.pem}"
SERVER_CERT="${SERVER_CERT:-/etc/ssl/certs/server-cert.pem}"
SERVER_TCP_PORT="${SERVER_PORT:-10514}"
REMOTE_LOGS_PATH="${REMOTE_LOGS_PATH:-/logs/remote}"
LOGZIO_TOKEN="${LOGZIO_TOKEN:-}"
LOGZIO_TOKEN_FILE="${LOGZIO_TOKEN_FILE:-}"
TIME_ZONE="${TIME_ZONE:-}"
TIME_SERVER="${TIME_SERVER:-'pool.ntp.org'}"

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

# Make sure required files and directories exist
mkdir -p /var/spool/rsyslog
touch /var/log/messages

# Generate RSysLog default configuration
read -r -d '' RSYSLOG_CONF <<RSYSLOG_CONF || true
# Global configuration
global(
  processInternalMessages="on"
  WorkDirectory="/var/spool/rsyslog"
  defaultNetstreamDriver="gtls"
  defaultNetstreamDriverCAFile="${CA_CERT}"
  defaultNetstreamDriverCertFile="${SERVER_CERT}"
  defaultNetstreamDriverKeyFile="${SERVER_KEY}"
)

# Provides support for local system logging (e.g. via logger command)
module(load="imuxsock")

# Provides --MARK-- message capability
module(load="immark")

module(load="omstdout")

# Provides TCP syslog reception
module(
  load="imtcp"
  MaxSessions="500"
  StreamDriver.Name="gtls"
  StreamDriver.mode="1"
  StreamDriver.AuthMode="anon"
)
input(
  type="imtcp"
  port="${SERVER_TCP_PORT}"
)

# Log all rsyslog messages to the console.
syslog.*  :omstdout:

# Separate logs by hostname
template(name="dynaFile" type="string" string="${REMOTE_LOGS_PATH}/%HOSTNAME%.log")
*.* action(type="omfile" dynaFile="dynaFile")
RSYSLOG_CONF

# Generate RSysLog Logz.io configuration
file_env LOGZIO_TOKEN # Read env var or file
read -r -d '' LOGZIO <<LOGZIO || true
# Logz.io
template(name="logzioFormat" type="string" string="[${LOGZIO_TOKEN}] <%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msgid% [type=syslog] %msg%\\n")
*.* action(
  type="omfwd"
  Protocol="tcp"
  Target="listener.logz.io"
  Port="5001"
  StreamDriverMode="1"
  StreamDriver="gtls"
  StreamDriverAuthMode="x509/name"
  StreamDriverPermittedPeers="*.logz.io"
  template="logzioFormat"
  queue.filename="fwdRule1"
  queue.maxdiskspace="1g"
  queue.saveonshutdown="on"
  queue.type="LinkedList"
)
LOGZIO
if [[ -n "$LOGZIO_TOKEN" ]] && [[ -s "$CA_CERT" ]]; then
  RSYSLOG_CONF+=$'\n\n'
  RSYSLOG_CONF+="$LOGZIO"
fi

# Configure timezone if provided
if [[ -n "${TIME_ZONE:-}" ]]; then
  cp "/usr/share/zoneinfo/${TIME_ZONE}" /etc/localtime
  echo "$TIME_ZONE" > /etc/timezone
fi

# Update time
ntpd -q -p "$TIME_SERVER" || true

# Remove previous PID file
rm -f /var/run/rsyslogd.pid

# Execute rsyslogd
echo "$RSYSLOG_CONF" > /etc/rsyslog.conf
/usr/sbin/rsyslogd -n
