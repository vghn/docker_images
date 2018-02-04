# Vlad's RSysLog

[![](https://images.microbadger.com/badges/image/vladgh/rs.svg)](https://microbadger.com/images/vladgh/rs "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/rs.svg)](https://microbadger.com/images/vladgh/rs "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/rs.svg)](https://microbadger.com/images/vladgh/rs "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/rs.svg)](https://microbadger.com/images/vladgh/rs "Get your own license badge on microbadger.com")

Vlad's central RSysLog server.

## Environment variables :

- `CA_CERT`: the path to the CA certificate (defaults to `/etc/ssl/certs/ca-cert.pem`)
- `SERVER_KEY`: the path to the server key (defaults to `/etc/ssl/certs/server-key.pem`)
- `SERVER_CERT`: the path to the server certificate (defaults to `/etc/ssl/certs/server-cert.pem`)
- `SERVER_TCP_PORT`: the port on which the server listens for logs (defaults to `10514`)
- `REMOTE_LOGS_PATH`: the path for the remote logs storage (defaults to `/logs/remote`)
- `LOGZIO_TOKEN`: Logz.io token (optional)
- `TIME_ZONE`: sets the time zone (optional)
- `TIME_SERVER`: sets the NTP time server (optional)

## Usage

```
docker run -d \
  -e LOGZIO_TOKEN='myToken' \
  -e TIME_ZONE='US/Central' \
  -v ./certs:/etc/ssl/certs:ro \
  -v ./remote_logs:/logs/remote
  vladgh/rs
```
