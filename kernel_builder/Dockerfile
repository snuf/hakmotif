FROM ubuntu:20.10
MAINTAINER funs@barred.org

ARG apt_proxy
ARG proxy_enabled

USER root
RUN if [[ "$apt_proxy" -a "$proxy_enabled" == "true" ]]; then \
  echo "Acquire::http::Proxy \"$apt_proxy\";" > /etc/apt/apt.conf.d/01proxy; \
  fi 
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y gcc sudo cpio \
  git make fakeroot build-essential \
  debhelper libelf-dev libssl-dev \
  bc bison flex kmod tar rsync pigz
# perf
RUN apt-get -y install libunwind-dev systemtap-sdt-dev libperl-dev \
  libnuma-dev liblzma-dev libbabeltrace-ctf-dev libiberty-dev \
  libslang2-dev binutils-dev libbabeltrace-dev \
  libaudit-dev openjdk-8-jdk-headless

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
