FROM centos:7

MAINTAINER James Eckersall <james.eckersall@gmail.com>

ARG JACKETT_VERSION=v0.8.1258
ARG JACKETT_URL=https://github.com/Jackett/Jackett/releases/download/v0.8.1258/Jackett.Binaries.Mono.tar.gz

RUN \
  yum install -y epel-release yum-utils && \
  rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" && \
  yum-config-manager --add-repo http://download.mono-project.com/repo/centos/ && \
  yum install -y curl gettext mono-core mono-devel mono-locale-extras wget && \
  yum clean all && \
  rm -rf /var/cache/yum/*
RUN \
  mkdir --mode=0777 /config && \
  curl -L "${JACKETT_URL}" -o /tmp/Jackett.tar.gz && \
  tar -xvf /tmp/Jackett.tar.gz -C / && \
  rm -f /tmp/Jackett.tar.gz && \
  chmod -R 0775 /var/log /config /Jackett

EXPOSE 9117

ENV XDG_CONFIG_HOME /config

VOLUME ["/config"]

ENTRYPOINT [ "/usr/bin/mono", "/Jackett/JackettConsole.exe", "-d", "/config" ]
