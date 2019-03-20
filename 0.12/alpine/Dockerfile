# Build stage for BerkeleyDB
FROM alpine as berkeleydb

ENV BERKELEYDB_VERSION=db-4.8.30.NC
ENV BERKELEYDB_PREFIX=/opt/${BERKELEYDB_VERSION}

RUN apk --no-cache add autoconf automake build-base libressl \
    && wget https://download.oracle.com/berkeley-db/${BERKELEYDB_VERSION}.tar.gz \
    && tar -xzf *.tar.gz \
    && sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i ${BERKELEYDB_VERSION}/dbinc/atomic.h \
    && mkdir -p ${BERKELEYDB_PREFIX}

WORKDIR /${BERKELEYDB_VERSION}/build_unix

RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BERKELEYDB_PREFIX} \
    && make -j4 \
    && make install \
    && rm -rf ${BERKELEYDB_PREFIX}/docs

# Build stage for Sparks
FROM alpine as sparks

COPY --from=berkeleydb /opt /opt

ENV SPARKS_VERSION=0.12.3.6
ENV SPARKS_PREFIX=/opt/sparks-${SPARKS_VERSION}

RUN apk --no-cache add autoconf automake boost-dev build-base chrpath file gnupg libevent-dev libressl libressl-dev libsodium-dev libtool linux-headers protobuf-dev zeromq-dev \
    && set -ex \
    && for key in \
      38EE12EB597B4FC0 \
      ; do \
      gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
      gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
      gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
      gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
    done \
    && wget https://github.com/sparkspay/sparks/archive/v${SPARKS_VERSION}.tar.gz \
    && tar -xzf *.tar.gz \
    && ls -la

WORKDIR /sparks-${SPARKS_VERSION}

RUN sed -i '/AC_PREREQ/a\AR_FLAGS=cr' src/univalue/configure.ac \
    && sed -i '/AX_PROG_CC_FOR_BUILD/a\AR_FLAGS=cr' src/secp256k1/configure.ac \
    && sed -i s:sys/fcntl.h:fcntl.h: src/compat.h \
    && ./autogen.sh \
    && ./configure LDFLAGS=-L`ls -d /opt/db*`/lib/ CPPFLAGS=-I`ls -d /opt/db*`/include/ \
      --prefix=${SPARKS_PREFIX} \
      --mandir=/usr/share/man \
      --disable-tests \
      --disable-bench \
      --disable-ccache \
      --with-gui=no \
      --with-utils \
      --with-libs \
      --with-daemon \
    && make -j4 \
    && make install \
    && strip ${SPARKS_PREFIX}/bin/sparks-cli \
    && strip ${SPARKS_PREFIX}/bin/sparks-tx \
    && strip ${SPARKS_PREFIX}/bin/sparksd \
    && strip ${SPARKS_PREFIX}/lib/libsparksconsensus.a \
    && strip ${SPARKS_PREFIX}/lib/libsparksconsensus.so.0.0.0

# Build stage for compiled artifacts
FROM alpine

LABEL maintainer.0="Mircea Rila (@zaWasp)"

ENV SPARKS_DATA=/home/sparks/.sparkscore
ENV SPARKS_VERSION=0.12.3.6
ENV SPARKS_PREFIX=/opt/sparks-${SPARKS_VERSION}
ENV PATH=${SPARKS_PREFIX}/bin:$PATH

RUN adduser -S sparks \
    && apk --no-cache add boost boost-program_options curl libevent libressl libzmq su-exec

COPY --from=sparks /opt /opt
COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ["/home/sparks/.sparkscore"]

EXPOSE 8890 8891 9998 19998

ENTRYPOINT ["/entrypoint.sh"]

CMD ["sparksd"]
