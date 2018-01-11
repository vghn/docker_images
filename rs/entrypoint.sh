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
SERVER_PORT="${SERVER_PORT:-10514}"
REMOTE_LOGS_PATH="${REMOTE_LOGS_PATH:-/logs/remote}"
LOGZIO_TOKEN="${LOGZIO_TOKEN:-}"

# Make sure required files and directories exist
mkdir -p /var/spool/rsyslog
touch /var/log/messages

# Generate RSysLog default configuration
read -r -d '' RSYSLOG_CONF <<'RSYSLOG_CONF' || true
# Input modules
$ModLoad immark.so   # provide --MARK-- message capability
$ModLoad imuxsock.so # provide local system logging (e.g. via logger command)
$ModLoad imtcp       # provides TCP syslog reception

# Output modules
$ModLoad omstdout.so # provide messages to stdout

# Setup disk assisted queues. An on-disk queue is created for this action.
# If the remote host is down, messages are spooled to disk and sent when
# it is up again.
$WorkDirectory /var/spool/rsyslog # where to place spool files
$ActionQueueFileName fwdRule1     # unique name prefix for spool files
$ActionQueueMaxDiskSpace 1g       # 1gb space limit (use as much as possible)
$ActionQueueSaveOnShutdown on     # save messages to disk on shutdown
$ActionQueueType LinkedList       # run asynchronously
$ActionResumeRetryCount -1        # infinite retries if host is down
RSYSLOG_CONF

# Generate RSysLog TLS configuration
read -r -d '' RSYSLOG_TLS <<RSYSLOG_TLS || true
# Rsyslog TLS
\$DefaultNetstreamDriver gtls
\$DefaultNetstreamDriverCAFile ${CA_CERT}
\$DefaultNetstreamDriverCertFile ${SERVER_CERT}
\$DefaultNetstreamDriverKeyFile ${SERVER_KEY}
\$InputTCPServerStreamDriverAuthMode anon
\$InputTCPServerStreamDriverMode 1
RSYSLOG_TLS

if [[ -s "$CA_CERT" ]] && [[ -s "$SERVER_CERT" ]] && [[ -s "$SERVER_KEY" ]]; then
  RSYSLOG_CONF+=$'\n\n'
  RSYSLOG_CONF+="$RSYSLOG_TLS"
fi

# Generate RSysLog Server configuration
read -r -d '' RSYSLOG_SERVER <<RSYSLOG_SERVER || true
# TCP Syslog Server
\$InputTCPServerRun ${SERVER_PORT}

# Log all rsyslog messages to the console.
syslog.*  :omstdout:

# Separate logs by hostname
template(name="dynaFile" type="string" string="${REMOTE_LOGS_PATH}/%HOSTNAME%.log")
*.* action(type="omfile" dynaFile="dynaFile")
RSYSLOG_SERVER
RSYSLOG_CONF+=$'\n\n'
RSYSLOG_CONF+="$RSYSLOG_SERVER"

# Generate RSysLog Logz.io configuration
read -r -d '' LOGZIO <<LOGZIO || true
# Logz.io
template(name="logzioFormat" type="string" string="[${LOGZIO_TOKEN}] <%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msgid% [type=syslog] %msg%\\n")
*.* action(type="omfwd" Protocol="tcp" Target="listener.logz.io" Port="5001" StreamDriverMode="1" StreamDriver="gtls" StreamDriverAuthMode="x509/name" StreamDriverPermittedPeers="*.logz.io" template="logzioFormat")
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

# Configure timeserver if not provided
if [[ -z "${TIME_SERVER:-}" ]]; then
  TIME_SERVER='pool.ntp.org'
fi

# Update time
ntpd -p "$TIME_SERVER" || true

# Remove previous PID file
rm -f /var/run/rsyslogd.pid

# Execute rsyslogd
echo "$RSYSLOG_CONF" > /etc/rsyslog.conf
/usr/sbin/rsyslogd -n
