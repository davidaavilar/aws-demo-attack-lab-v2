# Stage 1: Java donor (apt-capable)
FROM eclipse-temurin:17-jre-noble AS jre_donor
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      curl \
      locales="$(apt-cache policy locales | awk '/Candidate:/ {print $$2}')" \
      libfreetype6="$(apt-cache policy libfreetype6 | awk '/Candidate:/ {print $$2}')" \
      fontconfig="$(apt-cache policy fontconfig | awk '/Candidate:/ {print $$2}')" \
      fonts-dejavu-core="$(apt-cache policy fonts-dejavu-core | awk '/Candidate:/ {print $$2}')"; \
    rm -rf /var/lib/apt/lists/*; \
    localedef -i es_EC -f UTF-8 es_EC.utf8 --no-archive; \
    ln -sf /usr/share/zoneinfo/America/Guayaquil /etc/localtime; \
    printf '%s\n' "America/Guayaquil" > /etc/timezone; \
    JAVA_VER="$(java -version 2>&1 | head -n1)"; \
    printf '%s\n' "$JAVA_VER" | grep -qE '(openjdk version "17|Temurin.*17)' || { printf 'ERROR: Java installation validation failed - got: %s\n' "$JAVA_VER" >&2; exit 1; }; \
    JAVA_PATCH="${JAVA_VER#*\"}"; JAVA_PATCH="${JAVA_PATCH%%\"*}"; \
    printf 'INFO: donor Java patch in use: %s\n' "$JAVA_PATCH"

# Stage 2: Final DHI runtime
FROM dhi.io/debian-base:trixie
SHELL ["/bin/sh", "-eu", "-c"]

USER 0:0

COPY --from=jre_donor /opt/java/openjdk /opt/java/openjdk
COPY --from=jre_donor /etc/localtime /etc/localtime
COPY --from=jre_donor /etc/timezone /etc/timezone
COPY --from=jre_donor /usr/lib/locale/es_EC.utf8 /usr/lib/locale/es_EC.utf8
COPY --from=jre_donor /usr/share/zoneinfo/America/Guayaquil /usr/share/zoneinfo/America/Guayaquil
COPY --from=jre_donor /usr/bin/curl /usr/bin/curl
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libcurl.so.4* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libssl.so.3* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libcrypto.so.3* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libnghttp2.so.14* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libidn2.so.0* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libpsl.so.5* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/librtmp.so.1* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libssh.so.4* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libkrb5.so.3* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libk5crypto.so.3* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libkrb5support.so.0* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libkeyutils.so.1* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libcom_err.so.2* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libldap.so.2* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/liblber.so.2* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libsasl2.so.2* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libzstd.so.1* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libz.so.1* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libbrotlidec.so.1* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libunistring.so.5* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libgnutls.so.30* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libhogweed.so.6* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libnettle.so.8* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libgmp.so.10* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libp11-kit.so.0* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libtasn1.so.6* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libresolv.so.2* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libffi.so.8* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/bin/sed /usr/bin/sed
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libfreetype.so.6* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/
COPY --from=jre_donor /lib/x86_64-linux-gnu/libbz2.so.1.0 /lib/x86_64-linux-gnu/
COPY --from=jre_donor /lib/x86_64-linux-gnu/libpng16.so.16 /lib/x86_64-linux-gnu/
COPY --from=jre_donor /lib/x86_64-linux-gnu/libbrotlidec.so.1 /lib/x86_64-linux-gnu/
COPY --from=jre_donor /lib/x86_64-linux-gnu/libbrotlicommon.so.1 /lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libfontconfig.so.1 /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libexpat.so.1 /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /lib/x86_64-linux-gnu/libuuid.so.1 /lib/x86_64-linux-gnu/
COPY --from=jre_donor /etc/fonts /etc/fonts
COPY --from=jre_donor /usr/share/fonts/truetype/dejavu /usr/share/fonts/truetype/dejavu

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="/opt/java/openjdk/bin:${PATH}"
ENV LANG=es_EC.UTF-8
ENV LANGUAGE=es_EC:es
ENV LC_ALL=es_EC.UTF-8
ENV TZ=America/Guayaquil

LABEL org.opencontainers.image.title="Banco Pichincha Golden Image OpenJDK 17 Hardened (DHI Debian 13)" \
      org.opencontainers.image.description="Base de runtime Java 17, regionalización Ecuador, hardening, non-root, Spring Boot ready, 0 CRITICAL CVEs, <200MB." \
      org.opencontainers.image.vendor="Banco Pichincha" \
      org.opencontainers.image.authors="arquitectura@pichincha.com" \
      org.opencontainers.image.version="17"

RUN set -eux; \
  JAVA_VER="$(java -version 2>&1 | head -n1)"; \
  case "$JAVA_VER" in \
    *'openjdk version "17'*|*Temurin*17*) : ;; \
    *) printf 'ERROR: Java runtime validation failed - got: %s\n' "$JAVA_VER" >&2; exit 1 ;; \
  esac; \
  JAVA_PATCH="${JAVA_VER#*\"}"; JAVA_PATCH="${JAVA_PATCH%%\"*}"; \
  printf 'INFO: final-stage Java patch in use: %s\n' "$JAVA_PATCH"; \
  mkdir -p /opt/build/logs /opt/build/config /opt/build/tmp /opt/build/data; \
  chmod 755 /opt/build; \
  chmod 750 /opt/build/config; \
  chmod 770 /opt/build/logs /opt/build/tmp /opt/build/data; \
  chown -R 65532:65532 /opt/build; \
  mkdir -p /usr/local/share/ca-certificates; \
  chown 0:65532 /usr/local/share/ca-certificates; \
  chmod 750 /usr/local/share/ca-certificates; \
  rm -rf /usr/share/doc /usr/share/man /usr/share/info /usr/share/locale/* /usr/share/i18n/* \
         /var/cache/* /var/tmp/* /tmp/* /root/.cache || true; \
  rm -f /usr/bin/sudo /usr/bin/su /usr/bin/doas /usr/bin/gcc /usr/bin/g++ /usr/bin/make \
        /usr/bin/cmake /usr/bin/ld /usr/bin/gdb /usr/bin/strace /usr/bin/ltrace \
        /usr/bin/perl /usr/bin/python* /usr/bin/ruby /usr/bin/node /usr/bin/php /usr/bin/lua \
        /usr/bin/telnet /usr/bin/ftp /usr/bin/nc /usr/bin/ping \
        /usr/bin/dig /usr/bin/nslookup /usr/bin/host || true; \
  test -d /usr/local/share/ca-certificates; \
  test -f /usr/lib/x86_64-linux-gnu/libfreetype.so.6; \
  test -f /usr/lib/x86_64-linux-gnu/libfontconfig.so.1 && test -d /etc/fonts && test -d /usr/share/fonts/truetype/dejavu; \
  test -x /usr/bin/sed; \
  curl --version >/dev/null 2>&1 || { printf 'ERROR: curl runtime check failed - missing shared library dependency\n' >&2; exit 1; }; \
  java -version >/dev/null 2>&1; \
  printf '%s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" > /opt/.build-timestamp

WORKDIR /opt/build
USER 65532:65532