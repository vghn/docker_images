# Vlad's LetsEncrypt

## ***Abandoned in favor of [Acme.sh](https://acme.sh)***

[![Docker Layers](https://images.microbadger.com/badges/image/vladgh/le.svg)](http://microbadger.com/images/vladgh/le)
[![Docker Version](https://images.microbadger.com/badges/version/vladgh/le.svg)](http://microbadger.com/images/vladgh/le)
[![Docker Commit](https://images.microbadger.com/badges/commit/vladgh/le.svg)](http://microbadger.com/images/vladgh/le)
[![License](https://images.microbadger.com/badges/license/vladgh/le.svg)](http://microbadger.com/images/vladgh/le)
[![Docker Pulls](https://img.shields.io/docker/pulls/vladgh/le.svg)](https://hub.docker.com/r/vladgh/le)
[![Build Status](https://travis-ci.org/vghn/docker_images.svg?branch=master)](https://travis-ci.org/vghn/docker_images)

Automatically create or renew certificates on startup and daily thereafter. It creates a temporary certificate first so that the load balancer (ex. HAProxy) is able to start with HTTPS active.
When choosing the `http` challenge (default), a basic web server is created for the authentication.
When choosing the 'dns' challenge (`PREFERRED_CHALLENGE=dns`) the TXT records of the specified domains will be updated. Currently only Cloudflare is supported

Based on https://quay.io/repository/letsencrypt/letsencrypt and https://github.com/cnadeau/letsencrypt-dockercloud-haproxy

### Changes:

#### Environment variables:
- `CERTBOT_EXTRA_OPTIONS`: additional arguments to `certbot` (e.g. `--staging`)

  ***VERY IMPORTANT***

  Make sure you set the environment variable `CERTBOT_EXTRA_OPTIONS='--staging'` on the letsencrypt
  service  until you are 100% sure you are configured properly and you want to get
  a real certificate. Otherwise you’ll reach the 5 certificates limit per domain
  per week and you’ll end up waiting a week before being able to regenerate a valid
  certificate if you didn’t backup the ones already generated

- `DOMAINS`: [required] a list of domains and subdomains. Certificates from different domains are separated by semi-colon (;) and subdomains are separated by comma (,).

  Ex: DOMAINS='foo.com,www.foo.com;bar.com,www.bar.com'

  Note that currently atypical domain names are not yet supported (Ex: subdomain.other subdomain.example.com.uk)

- `EMAIL`: [required] the email address to be used for all certificates

- `CRONJOB`: if this is `true` (default) the container will run as cron deamon with a daily task that renews the certificates

- `GENERATE_TEMP_CERTIFICATE`: useful if the certbot server is behind a load balancer and a certificate is required for it to start. A temporary self signed certificate will be created and used until the challenge is authenticated (defaults to `false`)

- `PREFERRED_CHALLENGE`: the preferred authentication method (defaults to `http`); possible values: `http`, `dns`; for `dns` the script will try to autodetect based on the API keys present bellow.

  - CLOUDFLARE:
    - `CLOUDFLARE_EMAIL`: the email address to be used for dns authentication
    - `CLOUDFLARE_API_KEY`: the Cloudflare Global API Key

    For docker swarm you can also use a secret called `cloudflare_credentials.ini` which contains the email and api key, in the following format:

      ```
      # Cloudflare API credentials used by Certbot
      dns_cloudflare_email = cloudflare@example.com
      dns_cloudflare_api_key = 0123456789abcdef0123456789abcdef01234567
      ```

#### Packages:
- bash
- certbot
- curl
- jq
- openssl
- tini
