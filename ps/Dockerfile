FROM vladgh/puppetserverdb:0.2
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV AWS_DEFAULT_REGION='us-east-1' \
    AWS_SDK_VERSION='~> 2.0' \
    AUTOSIGN='/usr/local/bin/csr-sign'

# Install AWS SDK
RUN gem install aws-sdk:"${AWS_SDK_VERSION}" --no-ri --no-rdoc

# Copy configuration files
COPY csr-sign /usr/local/bin/csr-sign

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vendor="Puppet" \
      org.label-schema.url="https://github.com/puppetlabs/puppetserver" \
      org.label-schema.name="Vlad's Puppet Server with PuppetDB" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
