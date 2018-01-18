FROM ruby:2.4-alpine
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install packages
RUN apk --no-cache add ca-certificates curl openssl tini

# Install gems
COPY app/gems.rb /app/gems.rb
RUN apk --no-cache add --virtual build-dependencies ruby-dev build-base && \
    cd /app && bundle install --without development && \
    apk del build-dependencies

# Environment
ENV APP_PORT=8523 \
    APP_ENV=production

# Expose ports
EXPOSE $APP_PORT

# Copy application
COPY app /app

# Start server
WORKDIR /app
ENTRYPOINT [ "/sbin/tini", "--"]
CMD bundle exec puma --environment $APP_ENV --port $APP_PORT

# Health
HEALTHCHECK --interval=30s --timeout=30s --retries=10 CMD \
  curl --silent --fail "http://localhost:${APP_PORT}/status" || exit 1

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.name="Vlad's WebHook" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
