FROM vladgh/puppetserver:latest
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV AWS_DEFAULT_REGION='us-east-1' \
    AWS_SDK_VERSION='~> 2.0' \
    HIERA_EYAML_VERSION='~> 2.0'

# Install Hiera EYaml
RUN puppetserver gem install hiera-eyaml:"${HIERA_EYAML_VERSION}" --no-ri --no-rdoc

# Install AWS SDK
RUN gem install aws-sdk:"${AWS_SDK_VERSION}" --no-ri --no-rdoc

# Copy config files
COPY hiera.yaml /etc/puppetlabs/puppet/hiera.yaml

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
