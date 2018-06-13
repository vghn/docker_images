# Vlad's Load Balancer

## ***Abandoned in favor of [Traefik](https://traefik.io)***

[![Docker Layers](https://images.microbadger.com/badges/image/vladgh/lb.svg)](http://microbadger.com/images/vladgh/lb)
[![Docker Version](https://images.microbadger.com/badges/version/vladgh/lb.svg)](http://microbadger.com/images/vladgh/lb)
[![Docker Commit](https://images.microbadger.com/badges/commit/vladgh/lb.svg)](http://microbadger.com/images/vladgh/lb)
[![License](https://images.microbadger.com/badges/license/vladgh/lb.svg)](http://microbadger.com/images/vladgh/lb)
[![Docker Pulls](https://img.shields.io/docker/pulls/vladgh/lb.svg)](https://hub.docker.com/r/vladgh/lb)
[![Build Status](https://travis-ci.org/vghn/docker_images.svg?branch=master)](https://travis-ci.org/vghn/docker_images)


Based on https://hub.docker.com/r/dockercloud/haproxy/ and https://github.com/cnadeau/letsencrypt-dockercloud-haproxy

### Changes:

#### Environment variables:
- `LIVE_CERT_FOLDER`: the live certificates folder, which is monitored for changes (defaults to `/etc/letsencrypt/live`)
- `IGNORE_SECS`: number of seconds to ignore changes in order to avoid multiple restarts (defaults to `10`)

#### Note
Set the following environment variables on the letsencrypt container to ensure that it handles letsencrypt traffic
```
VIRTUAL_HOST="*/.well-known/acme-challenge/*"
VIRTUAL_HOST_WEIGHT="999"
```

#### Packages:
- bash
- inotify-tools
