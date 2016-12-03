FROM ubuntu:16.04
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/usr/local/bin:$PATH \
    PUPPETLABS_RELEASE='puppetlabs-release-pc1-xenial' \
    PUPPET_SERVER_VERSION="2.7.1" \
    JAVA_ARGS="-Xms512m -Xmx512m" \
    AWS_DEFAULT_REGION='us-east-1'

# Installation
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    wget -O "/tmp/${PUPPETLABS_RELEASE}.deb" \
    "https://apt.puppetlabs.com/${PUPPETLABS_RELEASE}.deb" && \
    dpkg -i "/tmp/${PUPPETLABS_RELEASE}.deb" && \
    apt-get update -y && apt-get install -y --no-install-recommends \
    puppetserver="$PUPPET_SERVER_VERSION"-1puppetlabs1 && \
    sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{JAVA_ARGS:-\1\}@' \
    /etc/default/puppetserver && \
    apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install packages
RUN gem install aws-sdk --no-ri --no-rdoc

# Ports
EXPOSE 8140

# Copy config files
COPY logback.xml request-logging.xml /etc/puppetlabs/puppetserver/
COPY hiera.yaml /etc/puppetlabs/puppet/hiera.yaml
COPY csr-sign /usr/local/bin/

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["puppetserver", "foreground"]

# Health
HEALTHCHECK --interval=30s --timeout=30s --retries=20 CMD \
  curl --fail -H 'Accept: pson' \
  --cert   $(puppet config print hostcert) \
  --key    $(puppet config print hostprivkey) \
  --cacert $(puppet config print localcacert) \
  https://$(puppet config print server):8140/production/status/no_key \
  || exit 1

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vendor="Puppet" \
      org.label-schema.url="https://github.com/puppetlabs/puppetserver" \
      org.label-schema.name="Puppet Server" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
