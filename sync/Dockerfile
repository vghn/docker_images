FROM alpine:3.4
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV AWS_DEFAULT_REGION=us-east-1

# Install packages
RUN apk --no-cache add \
    bash=4.3.42-r3 \
    git=2.8.3-r0 \
    inotify-tools=3.14-r2 \
    python=2.7.12-r0 && \
    apk --no-cache add --virtual build-dependencies py-pip && \
    pip install awscli==1.10.65 && \
    apk del build-dependencies

# Configure entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.name="VPM SYNC" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
