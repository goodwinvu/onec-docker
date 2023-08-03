ARG EDT_VERSION
ARG BASE_IMAGE=edt-native
ARG DOCKER_USERNAME

FROM ${DOCKER_USERNAME}/${BASE_IMAGE}:${EDT_VERSION}

RUN set -xe \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    curl \
    git \
    locales \
    openssh-client \
    wget \
  && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git-lfs \
  && rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8 \
  && wget -P /tmp https://gitlab.com/marmyshev/edt-editing/-/jobs/4592936268/artifacts/raw/public/repository-0.5.0-SNAPSHOT.zip \
  && export edt_path=$(dirname $(find /opt/1C/1CE -name 1cedt)) \
  && echo $edt_path \
  && $edt_path/1cedt -clean -purgeHistory -application org.eclipse.equinox.p2.director -noSplash -repository 'jar:file:/tmp/repository-0.5.0-SNAPSHOT.zip!/' -installIUs 'org.mard.dt.editing.feature.feature.group' \
  && ring edt platform-versions \
  && rm -f $edt_path/configuration/*.log \
  && rm -rf $edt_path/configuration/org.eclipse.core.runtime \
  && rm -rf $edt_path/configuration/org.eclipse.osgi \
  && rm -rf $edt_path/plugin-development \
  && rm -f $edt_path/plugins/com._1c.g5.v8.dt.platform.doc_*.jar \
  && rm -f $edt_path/plugins/com._1c.g5.v8.dt.product.doc_*.jar \
  && rm -f $edt_path/plugins/org.eclipse.egit.doc_*.jar \
  && rm -f $edt_path/plugins/org.eclipse.platform.doc_*.jar \
  && rm -rf /tmp/*

ENV LANG ru_RU.UTF-8

COPY ./jenkins-agent/docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh \
  && chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
