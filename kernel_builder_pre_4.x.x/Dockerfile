# FROM ubuntu:17.04
FROM ubuntu:14.04
MAINTAINER funs@barred.org

ARG apt_proxy

USER root
RUN echo "Acquire::http::Proxy \"$apt_proxy\";" > /etc/apt/apt.conf
RUN if $apt_proxy; then \
  echo "Acquire::http::Proxy \"http://192.168.0.16:8080\";" > /etc/apt/apt.conf; \
  fi 
RUN apt-get update
RUN apt-get install -y sudo
RUN sudo apt-get install -y gcc \
  git make fakeroot build-essential \
  debhelper libelf-dev libssl-dev \
  bc bison flex
RUN rm -rf /var/cache/apt && mkdir /var/cache/apt
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
RUN curl -o /usr/local/bin/mc \
  https://dl.minio.io/client/mc/release/linux-amd64/mc && \
  chmod +x /usr/local/bin/mc

WORKDIR /home/docker
USER root
COPY ./scripts/entrypoint.sh /home/docker/
RUN chmod +x /home/docker/entrypoint.sh

USER docker
ENTRYPOINT ["/home/docker/entrypoint.sh"]
CMD ["update"]

## clean image up
