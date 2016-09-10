# Sync Agent

[![Docker Layers](https://images.microbadger.com/badges/image/vladgh/vpm-sync.svg)](http://microbadger.com/images/vladgh/vpm-sync)
[![Docker Version](https://images.microbadger.com/badges/version/vladgh/vpm-sync.svg)](http://microbadger.com/images/vladgh/vpm-sync)
[![Docker Commit](https://images.microbadger.com/badges/commit/vladgh/vpm-sync.svg)](http://microbadger.com/images/vladgh/vpm-sync)
[![License](https://images.microbadger.com/badges/license/vladgh/vpm-sync.svg)](http://microbadger.com/images/vladgh/vpm-sync)
[![Docker Pulls](https://img.shields.io/docker/pulls/vladgh/vpm-sync.svg)](https://hub.docker.com/r/vladgh/vpm-sync)
[![Build Status](https://travis-ci.org/vghn/puppet-docker.svg?branch=master)](https://travis-ci.org/vghn/puppet-docker)

Watches for changes in a directory and syncs them to S3.
The container downloads first the S3 files (overwriting the local ones), and
then runs `aws s3 sync --delete` at the specified interval or when files are
changed. This script is intended for a single machine to sync it's files to S3,
and SHOULD NOT be used as a backup solution.

Optional variables :
- `AWS_ACCESS_KEY_ID` (or functional IAM profile)
- `AWS_SECRET_ACCESS_KEY` (or functional IAM profile)
- `AWS_DEFAULT_REGION` (or functional IAM profile)
- `S3PATH`: the S3 sync destination (reqired; ex: `s3://mybucket/myprefix`)
- `WATCHDIR`: the watched directory (defaults: `/watch`)
- `INTERVAL`: the number of seconds between S3 sync runs (default: `600`)
- `EVENTS`: the inotify events to watch for. Defaults to:
            'CREATE,DELETE,MODIFY,MOVE,MOVED_FROM,MOVED_TO'

Run command examples:

- Simple
```
docker run -d -e S3PATH=s3://mybucket/myprefix vladgh/vpm-sync
```

- External mounted `/watch` directory
```
docker run -d \
  -e S3PATH=s3://mybucket/myprefix \
  -v $(pwd):/watch \
  vladgh/vpm-sync
```

- Change the default directory
```
docker run -d \
  -e S3PATH=s3://mybucket/myprefix \
  -e WATCHDIR=/mywatchdir \
  vladgh/vpm-sync
```

- Change the default interval
```
docker run -d \
  -e S3PATH=s3://mybucket/myprefix \
  -e INTERVAL=3600 \
  vladgh/vpm-sync
```

- Provide the .aws config folder
```
docker run -d \
  -e S3PATH=s3://mybucket/myprefix \
  -v ~/.aws:/root/.aws \
  vladgh/vpm-sync
```

Based on https://github.com/danieldreier/docker-puppet-master-ssl
