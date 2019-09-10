# FROM ubuntu:17.04
FROM alpine
MAINTAINER funs@barred.org

ARG apt_proxy

USER root
RUN apk --update add git openssh curl bash && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*
RUN curl -o /usr/local/bin/mc \
  https://dl.minio.io/client/mc/release/linux-amd64/mc && \
  chmod +x /usr/local/bin/mc

COPY ./scripts/entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["update"]
## clean image up
