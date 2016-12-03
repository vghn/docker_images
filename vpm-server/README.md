# PuppetServer Docker Image

[![Docker Layers](https://images.microbadger.com/badges/image/vladgh/vpm-server.svg)](http://microbadger.com/images/vladgh/vpm-server)
[![Docker Version](https://images.microbadger.com/badges/version/vladgh/vpm-server.svg)](http://microbadger.com/images/vladgh/vpm-server)
[![Docker Commit](https://images.microbadger.com/badges/commit/vladgh/vpm-server.svg)](http://microbadger.com/images/vladgh/vpm-server)
[![License](https://images.microbadger.com/badges/license/vladgh/vpm-server.svg)](http://microbadger.com/images/vladgh/vpm-server)
[![Docker Pulls](https://img.shields.io/docker/pulls/vladgh/vpm-server.svg)](https://hub.docker.com/r/vladgh/vpm-server)
[![Build Status](https://travis-ci.org/vghn/puppet-docker.svg?branch=master)](https://travis-ci.org/vghn/puppet-docker)

Based on https://hub.docker.com/r/vladgh/puppetserver/

### Changes:

#### Packages:
- `aws-sdk` gem

#### Files:
- `csr-sign`: Policy-based auto signing script
- `hiera.yaml`: Hiera configuration file
