FROM gliderlabs/logspout:v3.2.3
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Install VladGh CA Root
COPY VladGhCARoot.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.name="VGH LOGSPOUT" \
      org.label-schema.url="$VCS_URL" \
      org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
