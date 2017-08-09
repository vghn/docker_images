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
- `OPTIONS`: additional arguments to `certbot` (e.g. `--staging`)

  ***VERY IMPORTANT***

  Make sure you set the environment variable OPTIONS: --staging on the letsencrypt
  service  until you are 100% sure you are configured properly and you want to get
  a real certificate. Otherwise you’ll reach the 5 certificates limit per domain
  per week and you’ll end up waiting a week before being able to regenerate a valid
  certificate if you didn’t backup the ones already generated

- `DOMAINS`: [required] a list of domains and subdomains. Certificates from different domains are separated by semi-colon (;) and subdomains are separated by comma (,).
  Ex: DOMAINS='foo.com,www.foo.com;bar.com,www.bar.com'

- `EMAIL`: [required] the email address to be used for all certificates

#### Packages:
- bash
- certbot
- openssl
