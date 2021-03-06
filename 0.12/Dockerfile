FROM debian:stable-slim

LABEL maintainer.0="Mircea Rila (@zaWasp)"

ENV GOSU_VERSION=1.10

RUN useradd -r sparks \
  && apt-get update -y \
  && apt-get install -y curl gnupg unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && set -ex \
  && for key in \
    B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    4B88269ABD8DF332 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
  done

RUN curl -o /usr/local/bin/gosu -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture) \
  && curl -o /usr/local/bin/gosu.asc -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu

ENV SPARKS_VERSION=0.12.3.6
ENV SPARKS_FOLDER_VERSION=0.12.3
ENV SPARKS_DATA=/home/sparks/.sparkscore \
  PATH=/opt/sparkscore-${SPARKS_FOLDER_VERSION}/bin:$PATH

RUN curl -SLO https://github.com/sparkspay/sparks/releases/download/v${SPARKS_VERSION}/sparkscore-${SPARKS_VERSION}-x86_64-linux-gnu.tar.gz \
  && tar -xzf sparkscore-${SPARKS_VERSION}-x86_64-linux-gnu.tar.gz -C /opt \
  && rm *.tar.gz

VOLUME ["/home/sparks/.sparkscore"]

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9998 9999 18332 19998 19999

CMD ["sparksd"]
