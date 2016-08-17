FROM vladgh/puppetserver:stable
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV AWS_DEFAULT_REGION='us-east-1'

# Install packages
RUN gem install aws-sdk --no-ri --no-rdoc

# Copy config files
COPY csr-sign /usr/local/bin/
COPY hiera.yaml /etc/puppetlabs/puppet/hiera.yaml

# Health
HEALTHCHECK --interval=30s --timeout=30s --retries=20 CMD \
  curl -H 'Accept: pson' \
  --cert   $(puppet config print hostcert) \
  --key    $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  https://$(puppet config print server):8140/production/status/no_key

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.license="Apache-2.0" \
      org.label-schema.version=$VERSION \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.docker.dockerfile="/Dockerfile"
