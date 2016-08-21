FROM ruby:alpine
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install packages
RUN apk --no-cache add openssl bash git python py-pip groff && \
    pip install awscli

# Set working directory
WORKDIR /app

# Install gems
COPY app/Gemfile /app/Gemfile
RUN apk --no-cache add --virtual build-dependencies ruby-dev build-base && \
    bundle install --without development && \
    apk del build-dependencies

# Environment
ENV RACK_PORT=8523 \
    RACK_ENV=production \
    AWS_DEFAULT_REGION=us-east-1

EXPOSE $RACK_PORT

# Copy application
COPY app /app

# Copy config files
COPY r10k.yaml /etc/puppetlabs/r10k/r10k.yaml

# Start server
ENTRYPOINT [ "sh", "-c", "bundle exec puma --environment $RACK_ENV --port $RACK_PORT"]

# Health
HEALTHCHECK --interval=30s --timeout=30s --retries=10 CMD \
  curl -sf "http://localhost:$RACK_PORT/status" || exit 1

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
