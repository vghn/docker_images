FROM dockercloud/haproxy:1.6.4
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install packages
RUN apk --no-cache add bash inotify-tools tini

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["dockercloud-haproxy"]

# Metadata params
ARG VERSION
ARG VCS_URL
ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vendor="Vlad Ghinea" \
      org.label-schema.url="https://ghn.me" \
      org.label-schema.name="Vlad's HAProxy" \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.vcs-url="$VCS_URL" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.docker.schema-version="1.0"
