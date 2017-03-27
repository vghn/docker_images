# Vlad's LetsEncrypt

[![Docker Layers](https://images.microbadger.com/badges/image/vladgh/le.svg)](http://microbadger.com/images/vladgh/le)
[![Docker Version](https://images.microbadger.com/badges/version/vladgh/le.svg)](http://microbadger.com/images/vladgh/le)
[![Docker Commit](https://images.microbadger.com/badges/commit/vladgh/le.svg)](http://microbadger.com/images/vladgh/le)
[![License](https://images.microbadger.com/badges/license/vladgh/le.svg)](http://microbadger.com/images/vladgh/le)
[![Docker Pulls](https://img.shields.io/docker/pulls/vladgh/le.svg)](https://hub.docker.com/r/vladgh/le)
[![Build Status](https://travis-ci.org/vghn/docker_images.svg?branch=master)](https://travis-ci.org/vghn/docker_images)

Automatically create or renew certificates on startup and daily thereafter.

Based on https://quay.io/repository/letsencrypt/letsencrypt and https://github.com/cnadeau/letsencrypt-dockercloud-haproxy


### Changes:

#### Environment variables:
- `DOMAINS`: [required] a list of domains and subdomains. Certificates from different domains are separated by semi-colon (;) and subdomains are separated by comma (,).
  Ex: DOMAINS=foo.com,www.foo.com;bar.com,www.bar.com
- `EMAIL`: [required] the email address to be used for all certificates
- `LOAD_BALANCER_SERVICE_NAME`: [required] used to wait for this service to be listening on port 80 before starting the certbot service.

#### Packages:
- bash
- certbot
- openssl
