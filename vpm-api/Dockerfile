FROM ruby:2.4-alpine
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install packages
RUN apk --no-cache add ca-certificates curl openssl

# https://github.com/docker-library/docker/blob/master/1.13/Dockerfile
ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.13.0
ENV DOCKER_SHA256 fc194bb95640b1396283e5b23b5ff9d1b69a5e418b5b3d774f303a7642162ad6
RUN set -x \
    && curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
    && echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
    && tar -xzvf docker.tgz \
    && mv docker/* /usr/local/bin/ \
    && rmdir docker \
    && rm docker.tgz \
    && docker -v

# Install gems
COPY app/Gemfile /app/Gemfile
RUN apk --no-cache add --virtual build-dependencies ruby-dev build-base && \
    cd /app && bundle install --without development && \
    apk del build-dependencies

# Environment
ENV RACK_PORT=8523 \
    RACK_ENV=production

# Expose ports
EXPOSE ${RACK_PORT}

# Copy application
COPY app /app

# Start server
WORKDIR /app
ENTRYPOINT [ "sh", "-c", "bundle exec puma --environment $RACK_ENV --port $RACK_PORT"]

# Health
HEALTHCHECK --interval=30s --timeout=30s --retries=10 CMD \
  curl --silent --fail "http://localhost:${RACK_PORT}/status" || exit 1

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
