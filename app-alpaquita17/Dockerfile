FROM bellsoft/liberica-runtime-container:jre-17-crac-glibc AS builder
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN set -eux; \
  apk add --no-cache glibc-locales tzdata icu-data-full curl freetype fontconfig font-dejavu sed; \
  echo 'America/Guayaquil' > /etc/timezone; \
  ln -sf /usr/share/zoneinfo/America/Guayaquil /etc/localtime; \
  localedef -i es_EC -f UTF-8 es_EC.utf8 --no-archive; \
  addgroup -g 10001 appuser; \
  adduser -u 10001 -G appuser -D -s /sbin/nologin -h /opt/build appuser; \
  mkdir -p /opt/build/logs /opt/build/config /opt/build/tmp /opt/build/data; \
  chmod 755 /opt/build; \
  chmod 770 /opt/build/logs /opt/build/tmp /opt/build/data; \
  chmod 750 /opt/build/config; \
  chown -R 10001:10001 /opt/build; \
  mkdir -p /usr/local/share/ca-certificates; \
  chown 10001:10001 /usr/local/share/ca-certificates; \
  chmod 750 /usr/local/share/ca-certificates; \
  "$JAVA_HOME/bin/java" -version 2>&1 | grep -qE '(Liberica|openjdk version \"17)'; \
  rm -rf /usr/share/doc /usr/share/man /usr/share/info; \
  rm -rf /usr/share/i18n/charmaps /usr/share/i18n/locales; \
  find /bin -type f -not -name 'ash' -exec rm -f {} +; \
  find /usr/bin -type f \( -name 'perl*' -o -name 'python*' -o -name 'ruby*' -o -name 'wget' -o -name 'nc' -o -name 'ssh' -o -name 'su' -o -name 'sudo' -o -name 'doas' \) -exec rm -f {} +; \
  find /usr/share/zoneinfo -mindepth 1 -maxdepth 1 ! -name 'America' -exec rm -rf {} + 2>/dev/null || true; \
  find /usr/share/zoneinfo/America -mindepth 1 ! -name 'Guayaquil' -exec rm -rf {} + 2>/dev/null || true; \
  apk del --no-network --purge apk-tools; \
  rm -rf /sbin /usr/sbin; \
  chmod 0555 /bin/* /usr/bin/* 2>/dev/null || true; \
  date -u > /opt/build/.build-timestamp; \
  test -f /etc/timezone && test -f /etc/localtime && test -d /opt/build/logs && test -x /usr/bin/curl && test -x /usr/bin/sed && test -f /usr/lib/libfreetype.so.6 && test -f /usr/lib/libbz2.so.1 && test -f /usr/lib/libpng16.so.16 && test -f /usr/lib/libfontconfig.so.1 && test -d /etc/fonts && test -d /usr/share/fonts/dejavu-core && test -d /usr/share/fonts/dejavu-extra && test -d /usr/lib/locale/es_EC.utf8 && test ! -x /sbin/apk

FROM bellsoft/hardened-liberica-runtime-container:jre-17-crac-glibc
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN addgroup -g 10001 appuser && adduser -u 10001 -G appuser -D -s /sbin/nologin -h /opt/build appuser && rm -f /usr/bin/sed /usr/bin/curl

COPY --from=builder /etc/timezone /etc/timezone
COPY --from=builder /etc/localtime /etc/localtime
COPY --from=builder /usr/lib/locale/es_EC.utf8 /usr/lib/locale/es_EC.utf8
COPY --from=builder /opt/build /opt/build
COPY --from=builder /usr/local/share/ca-certificates /usr/local/share/ca-certificates
COPY --from=builder /usr/share/zoneinfo/America/Guayaquil /usr/share/zoneinfo/America/Guayaquil
COPY --from=builder /usr/bin/curl /usr/bin/curl
COPY --from=builder /usr/bin/sed /usr/bin/sed
COPY --from=builder /opt/build/.build-timestamp /opt/build/.build-timestamp
COPY --from=builder /usr/lib/libcurl.so.4 /usr/lib/libcurl.so.4
COPY --from=builder /usr/lib/libcares.so.2 /usr/lib/libcares.so.2
COPY --from=builder /usr/lib/libnghttp2.so.14 /usr/lib/libnghttp2.so.14
COPY --from=builder /usr/lib/libidn2.so.0 /usr/lib/libidn2.so.0
COPY --from=builder /usr/lib/libpsl.so.5 /usr/lib/libpsl.so.5
COPY --from=builder /usr/lib/libssl.so.3 /usr/lib/libssl.so.3
COPY --from=builder /usr/lib/libcrypto.so.3 /usr/lib/libcrypto.so.3
COPY --from=builder /usr/lib/libzstd.so.1 /usr/lib/libzstd.so.1
COPY --from=builder /usr/lib/libbrotlidec.so.1 /usr/lib/libbrotlidec.so.1
COPY --from=builder /usr/lib/libunistring.so.5 /usr/lib/libunistring.so.5
COPY --from=builder /usr/lib/libbrotlicommon.so.1 /usr/lib/libbrotlicommon.so.1
COPY --from=builder /usr/lib/libfreetype.so.6 /usr/lib/libfreetype.so.6
COPY --from=builder /usr/lib/libfreetype.so.6.* /usr/lib/
COPY --from=builder /usr/lib/libbz2.so.1 /usr/lib/libbz2.so.1
COPY --from=builder /usr/lib/libpng16.so.16 /usr/lib/libpng16.so.16
COPY --from=builder /usr/lib/libfontconfig.so.1 /usr/lib/libfontconfig.so.1
COPY --from=builder /usr/lib/libexpat.so.1 /usr/lib/libexpat.so.1
COPY --from=builder /etc/fonts /etc/fonts
COPY --from=builder /usr/share/fonts /usr/share/fonts

RUN chown -R 10001:10001 /opt/build && \
    chmod 755 /opt/build && \
    chmod 770 /opt/build/logs /opt/build/tmp /opt/build/data && \
    chmod 750 /opt/build/config && \
    chown 10001:10001 /usr/local/share/ca-certificates && \
    chmod 750 /usr/local/share/ca-certificates

ENV JAVA_HOME=/usr/lib/jvm/liberica17-crac
ENV PATH="$JAVA_HOME/bin:/usr/bin:/bin"
ENV LANG=es_EC.utf8
ENV LC_ALL=es_EC.utf8
ENV TZ=America/Guayaquil

LABEL org.opencontainers.image.title="Golden Image OpenJDK 17 Hardened (Alpaquita GLIBC)" \
      org.opencontainers.image.description="Enterprise-grade security-hardened OpenJDK 17 base image for Banco Pichincha. Hardened, nonroot, read-only binaries, Kyverno CA, es_EC.UTF-8, America/Guayaquil." \
      org.opencontainers.image.version="17" \
      org.opencontainers.image.vendor="Banco Pichincha"

RUN test -f /etc/timezone && \
    test -f /etc/localtime && \
    test -d /opt/build/logs && \
    test -x /usr/bin/curl && \
    test -x /usr/bin/sed && \
    test -f /usr/lib/libfreetype.so.6 && \
    test -f /usr/lib/libbz2.so.1 && \
    test -f /usr/lib/libpng16.so.16 && \
    test -f /usr/lib/libfontconfig.so.1 && \
    test -d /etc/fonts && \
    test -d /usr/share/fonts/dejavu-core && \
    test -d /usr/share/fonts/dejavu-extra

WORKDIR /opt/build
USER 10001:10001