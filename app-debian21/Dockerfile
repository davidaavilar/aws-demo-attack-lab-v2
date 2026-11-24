# Stage 1: Java 21 donor (Ubuntu Noble - apt-capable)
FROM eclipse-temurin:21-jre-noble AS jre_donor
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
    printf '%s\n' "$JAVA_VER" | grep -qE '(openjdk version "21|Temurin.*21)' || { printf 'ERROR: Java 21 validation failed - got: %s\n' "$JAVA_VER" >&2; exit 1; }; \
    JAVA_PATCH="${JAVA_VER#*\"}"; JAVA_PATCH="${JAVA_PATCH%%\"*}"; \
    printf 'INFO: donor Java patch in use: %s\n' "$JAVA_PATCH"

# Stage 2: Final DHI runtime
FROM dhi.io/debian-base:trixie
SHELL ["/bin/sh", "-eu", "-c"]

LABEL org.opencontainers.image.title="Golden Image OpenJDK 21 Hardened (DHI Debian 13)"
LABEL org.opencontainers.image.description="Enterprise-grade security-hardened OpenJDK 21 base image for Banco Pichincha. Regionalized for Ecuador, non-root, ready for Spring Boot workloads, with Kyverno CA support."
LABEL org.opencontainers.image.vendor="Banco Pichincha"
LABEL org.opencontainers.image.authors="DevSecOps Team <devsecops@pichincha.com>"
LABEL org.opencontainers.image.version="21"

USER 0:0

COPY --from=jre_donor /opt/java/openjdk /opt/java/openjdk
COPY --from=jre_donor /etc/localtime /etc/localtime
COPY --from=jre_donor /etc/timezone /etc/timezone
COPY --from=jre_donor /usr/lib/locale/es_EC.utf8 /usr/lib/locale/es_EC.utf8
COPY --from=jre_donor /usr/share/zoneinfo/America/Guayaquil /usr/share/zoneinfo/America/Guayaquil
COPY --from=jre_donor /usr/bin/curl /usr/bin/curl
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libcurl.so.4* /usr/lib/x86_64-linux-gnu/
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
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libbrotlidec.so.1* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libunistring.so.5* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libgnutls.so.30* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libhogweed.so.6* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libnettle.so.8* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libp11-kit.so.0* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libtasn1.so.6* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libffi.so.8* /usr/lib/x86_64-linux-gnu/
COPY --from=jre_donor /usr/bin/sed /usr/bin/sed
COPY --from=jre_donor /usr/lib/x86_64-linux-gnu/libfreetype.so.6* /usr/lib/x86_64-linux-gnu/
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

RUN set -eux; \
  JAVA_VER="$(java -version 2>&1 | head -n1)"; \
  case "$JAVA_VER" in \
    *'openjdk version "21'*|*Temurin*21*) : ;; \
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
    rm -f \
        /usr/bin/perl* /usr/bin/python* /usr/bin/ruby /usr/bin/node /usr/bin/php /usr/bin/lua \
        /usr/bin/wget /usr/bin/nc /usr/bin/ssh /usr/bin/telnet /usr/bin/ftp \
        /usr/bin/dig /usr/bin/nslookup /usr/bin/host /usr/bin/ping \
        /usr/bin/gcc /usr/bin/make /usr/bin/cmake /usr/bin/ld /usr/bin/as \
        /usr/bin/vi /usr/bin/vim /usr/bin/nano /usr/bin/emacs \
        /usr/bin/strace /usr/bin/ltrace /usr/bin/gdb \
        /usr/bin/su /usr/bin/sudo \
        2>/dev/null || true; \
    rm -rf \
        /usr/share/doc/* /usr/share/man/* /usr/share/info/* \
        /usr/share/locale/* /usr/share/i18n/locales/* \
        /usr/share/pixmaps /usr/share/applications /usr/share/mime \
        /var/cache/* /var/log/* /var/tmp/* /tmp/* \
        /root/.cache \
        2>/dev/null || true; \
    test -d /usr/local/share/ca-certificates || { printf 'ERROR: ca-certificates directory missing\n' >&2; exit 1; }; \
    test -f /usr/lib/x86_64-linux-gnu/libfreetype.so.6 || { printf 'ERROR: libfreetype.so.6 missing\n' >&2; exit 1; }; \
    test -f /usr/lib/x86_64-linux-gnu/libfontconfig.so.1 && test -d /etc/fonts && test -d /usr/share/fonts/truetype/dejavu || { printf 'ERROR: fontconfig or DejaVu fonts missing\n' >&2; exit 1; }; \
    sed --version >/dev/null 2>&1 || { printf 'ERROR: sed runtime check failed (required by production init.sh entrypoint)\n' >&2; exit 1; }; \
    curl --version >/dev/null 2>&1 || { printf 'ERROR: curl runtime check failed - missing shared library dependency\n' >&2; exit 1; }; \
    openssl version >/dev/null 2>&1 || { printf 'ERROR: openssl runtime check failed - a donor COPY overwrote a base library\n' >&2; exit 1; }; \
    java -version >/dev/null 2>&1; \
    printf 'Image built: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > /opt/.build-timestamp; \
    printf 'Image: %s\n' 'Golden Image OpenJDK 21 Hardened (DHI Debian 13)' >> /opt/.build-timestamp; \
    printf 'OS: %s\n' "$(. /etc/os-release; printf '%s' "${PRETTY_NAME:-unknown}")" >> /opt/.build-timestamp; \
    printf 'Java: %s\n' "$(java -version 2>&1 | sed -n '/ version "/p')" >> /opt/.build-timestamp; \
    printf 'Java runtime: %s\n' "$(java -version 2>&1 | sed -n '/Runtime Environment/p')" >> /opt/.build-timestamp; \
    printf 'JAVA_HOME: %s\n' "$JAVA_HOME" >> /opt/.build-timestamp; \
    printf 'curl: %s\n' "$(curl --version | sed -n 1p)" >> /opt/.build-timestamp; \
    printf 'sed: %s\n' "$(sed --version | sed -n 1p)" >> /opt/.build-timestamp; \
    printf 'User: %s\n' '65532:65532' >> /opt/.build-timestamp; \
    printf 'Locale/TZ: %s / %s\n' "$LANG" "$TZ" >> /opt/.build-timestamp; \
    chmod 444 /opt/.build-timestamp; \
    test -s /opt/.build-timestamp

WORKDIR /opt/build
USER 65532:65532
