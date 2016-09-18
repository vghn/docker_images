FROM ruby:2.3-alpine
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install packages
RUN apk --no-cache add \
    bash=4.3.42-r3 \
    git=2.8.3-r0 \
    groff=1.22.3-r1 \
    openssl=1.0.2h-r2 \
    python=2.7.12-r0 && \
    apk --no-cache add --virtual build-dependencies py-pip && \
    pip install awscli==1.10.65 && \
    apk del build-dependencies

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

EXPOSE 8523

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
LABEL org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.name="VPM API" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
