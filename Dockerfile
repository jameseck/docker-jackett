FROM centos:7

MAINTAINER James Eckersall <james.eckersall@gmail.com>

RUN \
  yum install -y epel-release yum-utils && \
  rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" && \
  yum-config-manager --add-repo http://download.mono-project.com/repo/centos/ && \
  yum install -y curl gettext jq mono-core mono-devel mono-locale-extras wget && \
  yum clean all && \
  rm -rf /var/cache/yum/* && \
  mkdir --mode=0777 /config && \
  curl -L \
    $(curl -s \
        https://api.github.com/repos/Jackett/Jackett/releases/latest \
      | jq -r ".assets[] | select(.name | test(\"Jackett.Binaries.Mono.tar.gz\")) | .browser_download_url" \
    ) \
    -o /tmp/Jackett.tar.gz && \
  tar -xvf /tmp/Jackett.tar.gz -C / && \
  rm -f /tmp/Jackett.tar.gz && \
  chmod -R 0777 /var/log /config /Jackett

EXPOSE 9117

VOLUME ["/config"]

ENTRYPOINT [ "/usr/bin/mono", "/Jackett/JackettConsole.exe" ]
