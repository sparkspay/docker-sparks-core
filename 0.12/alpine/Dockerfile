# Build stage for BerkeleyDB
FROM alpine as berkeleydb

RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add build-base
RUN apk --no-cache add libressl

ENV BERKELEYDB_VERSION=db-4.8.30.NC
ENV BERKELEYDB_PREFIX=/opt/${BERKELEYDB_VERSION}

RUN wget https://download.oracle.com/berkeley-db/${BERKELEYDB_VERSION}.tar.gz
RUN tar -xzf *.tar.gz
RUN sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i ${BERKELEYDB_VERSION}/dbinc/atomic.h
RUN mkdir -p ${BERKELEYDB_PREFIX}

WORKDIR /${BERKELEYDB_VERSION}/build_unix

RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BERKELEYDB_PREFIX}
RUN make -j4
RUN make install
RUN rm -rf ${BERKELEYDB_PREFIX}/docs

# Build stage for Sparks
FROM alpine as sparks

COPY --from=berkeleydb /opt /opt

RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add boost-dev
RUN apk --no-cache add build-base
RUN apk --no-cache add chrpath
RUN apk --no-cache add file
RUN apk --no-cache add gnupg
RUN apk --no-cache add libevent-dev
RUN apk --no-cache add libressl
RUN apk --no-cache add libressl-dev
RUN apk --no-cache add libsodium-dev
RUN apk --no-cache add libtool
RUN apk --no-cache add linux-headers
RUN apk --no-cache add protobuf-dev
RUN apk --no-cache add zeromq-dev

RUN set -ex \
  && for key in \
    38EE12EB597B4FC0 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
  done

ENV SPARKS_VERSION=0.12.3.5
ENV SPARKS_PREFIX=/opt/sparks-${SPARKS_VERSION}

RUN wget https://github.com/sparkspay/sparks/archive/v${SPARKS_VERSION}.tar.gz
RUN tar -xzf *.tar.gz
RUN ls -la

WORKDIR /sparks-${SPARKS_VERSION}

RUN sed -i '/AC_PREREQ/a\AR_FLAGS=cr' src/univalue/configure.ac
RUN sed -i '/AX_PROG_CC_FOR_BUILD/a\AR_FLAGS=cr' src/secp256k1/configure.ac
RUN sed -i s:sys/fcntl.h:fcntl.h: src/compat.h
RUN ./autogen.sh
RUN ./configure LDFLAGS=-L`ls -d /opt/db*`/lib/ CPPFLAGS=-I`ls -d /opt/db*`/include/ \
  --prefix=${SPARKS_PREFIX} \
  --mandir=/usr/share/man \
  --disable-tests \
  --disable-bench \
  --disable-ccache \
  --with-gui=no \
  --with-utils \
  --with-libs \
  --with-daemon
RUN make -j4
RUN make install
RUN strip ${SPARKS_PREFIX}/bin/sparks-cli
RUN strip ${SPARKS_PREFIX}/bin/sparks-tx
RUN strip ${SPARKS_PREFIX}/bin/sparksd
RUN strip ${SPARKS_PREFIX}/lib/libsparksconsensus.a
RUN strip ${SPARKS_PREFIX}/lib/libsparksconsensus.so.0.0.0

# Build stage for compiled artifacts
FROM alpine

LABEL maintainer.0="Mircea Rila (@zaWasp)"

RUN adduser -S sparks
RUN apk --no-cache add \
  boost \
  boost-program_options \
  curl \
  libevent \
  libressl \
  libzmq \
  su-exec

ENV SPARKS_DATA=/home/sparks/.sparkscore
ENV SPARKS_VERSION=0.12.3.5
ENV SPARKS_PREFIX=/opt/sparks-${SPARKS_VERSION}
ENV PATH=${SPARKS_PREFIX}/bin:$PATH

COPY --from=sparks /opt /opt
COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ["/home/sparks/.sparkscore"]

EXPOSE 8890 8891 9998 19998

ENTRYPOINT ["/entrypoint.sh"]

CMD ["sparksd"]