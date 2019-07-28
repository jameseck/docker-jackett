FROM centos:7

MAINTAINER James Eckersall <james.eckersall@gmail.com>

ARG JACKETT_VERSION=
ARG JACKETT_URL=

ARG TINI_VERSION=v0.18.0

#  rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" && \
#  yum-config-manager --add-repo http://download.mono-project.com/repo/centos/ && \
#  yum install -y curl gettext mono-core mono-devel mono-locale-extras wget && \
RUN \
  yum install -y epel-release yum-utils && \
  yum install curl gettext wget && \
  yum clean all && \
  rm -rf /var/cache/yum/*
RUN \
  mkdir --mode=0777 /config && \
  curl -L "${JACKETT_URL}" -o /tmp/Jackett.tar.gz && \
  tar -xvf /tmp/Jackett.tar.gz -C / && \
  rm -f /tmp/Jackett.tar.gz && \
  chmod -R 0775 /var/log /Jackett

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

RUN \
  chmod +x /tini

COPY run.py /

EXPOSE 9117

ENV XDG_CONFIG_HOME /config

VOLUME ["/config"]

ENTRYPOINT ["/tini", "--"]
CMD ["/usr/bin/python2", "/run.py"]
