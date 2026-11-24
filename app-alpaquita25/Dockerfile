FROM bellsoft/liberica-runtime-container:jre-25-glibc AS builder
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN set -eux; \
    apk add --no-cache glibc-locales tzdata icu-data-full curl freetype fontconfig font-dejavu sed openssl; \
    echo 'America/Guayaquil' > /etc/timezone; \
    ln -sf /usr/share/zoneinfo/America/Guayaquil /etc/localtime; \
    localedef -i es_EC -f UTF-8 es_EC.utf8 --no-archive; \
    addgroup -g 65532 nonroot; \
    adduser -u 65532 -G nonroot -D -s /sbin/nologin -h /opt/build nonroot; \
    mkdir -p /opt/build/logs /opt/build/config /opt/build/tmp /opt/build/data; \
    chmod 755 /opt/build; \
    chmod 770 /opt/build/logs /opt/build/tmp /opt/build/data; \
    chmod 750 /opt/build/config; \
    chown -R 65532:65532 /opt/build; \
    mkdir -p /usr/local/share/ca-certificates; \
    chown 0:65532 /usr/local/share/ca-certificates; \
    chmod 750 /usr/local/share/ca-certificates; \
    "$JAVA_HOME/bin/java" -version 2>&1 | grep -qE '(Liberica|openjdk version \"25)'; \
    rm -rf /usr/share/doc /usr/share/man /usr/share/info; \
    rm -rf /usr/share/i18n/charmaps /usr/share/i18n/locales; \
    find /bin -type f -not -name 'ash' -exec rm -f {} +; \
    find /usr/bin -type f \( -name 'perl*' -o -name 'python*' -o -name 'ruby*' -o -name 'wget' -o -name 'nc' -o -name 'ssh' -o -name 'su' -o -name 'sudo' -o -name 'doas' \) -exec rm -f {} +; \
    find /usr/share/zoneinfo -mindepth 1 -maxdepth 1 ! -name 'America' -exec rm -rf {} + 2>/dev/null || true; \
    find /usr/share/zoneinfo/America -mindepth 1 ! -name 'Guayaquil' -exec rm -rf {} + 2>/dev/null || true; \
    apk del --no-network --purge apk-tools; \
    rm -rf /sbin /usr/sbin; \
    chmod 0555 /bin/* /usr/bin/* 2>/dev/null || true; \
    test -f /etc/timezone && test -f /etc/localtime && test -d /opt/build/logs && curl --version >/dev/null 2>&1 && sed --version >/dev/null 2>&1 && test -f /usr/lib/libfreetype.so.6 && test -f /usr/lib/libbz2.so.1 && test -f /usr/lib/libpng16.so.16 && test -f /usr/lib/libfontconfig.so.1 && test -d /etc/fonts && test -d /usr/share/fonts/dejavu-core && test -d /usr/share/fonts/dejavu-extra && test -d /usr/lib/locale/es_EC.utf8 && openssl version >/dev/null && test -s /etc/ssl/openssl.cnf && test -f /usr/lib/ossl-modules/legacy.so && test ! -x /sbin/apk

FROM bellsoft/hardened-liberica-runtime-container:jre-25-glibc
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN addgroup -g 65532 nonroot && \
    adduser -u 65532 -G nonroot -D -s /sbin/nologin -h /opt/build nonroot && \
    rm -f /usr/bin/sed /usr/bin/curl /usr/bin/nc /usr/bin/su

COPY --from=builder /etc/timezone /etc/timezone
COPY --from=builder /etc/localtime /etc/localtime
COPY --from=builder /usr/lib/locale/es_EC.utf8 /usr/lib/locale/es_EC.utf8
COPY --from=builder /opt/build /opt/build
COPY --from=builder /usr/local/share/ca-certificates /usr/local/share/ca-certificates
COPY --from=builder /usr/share/zoneinfo/America/Guayaquil /usr/share/zoneinfo/America/Guayaquil
COPY --from=builder /usr/bin/curl /usr/bin/curl
COPY --from=builder /usr/bin/sed /usr/bin/sed
COPY --from=builder /usr/bin/openssl /usr/bin/openssl
COPY --from=builder /etc/ssl/openssl.cnf /etc/ssl/openssl.cnf
COPY --from=builder /usr/lib/ossl-modules/legacy.so /usr/lib/ossl-modules/legacy.so
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

RUN chown -R 65532:65532 /opt/build && \
    chmod 755 /opt/build && \
    chmod 770 /opt/build/logs /opt/build/tmp /opt/build/data && \
    chmod 750 /opt/build/config && \
    chown 0:65532 /usr/local/share/ca-certificates && \
    chmod 750 /usr/local/share/ca-certificates

ENV LANG=es_EC.utf8
ENV LC_ALL=es_EC.utf8
ENV TZ=America/Guayaquil

LABEL org.opencontainers.image.title="Golden Image OpenJDK 25 Hardened (Alpaquita GLIBC)"
LABEL org.opencontainers.image.description="Enterprise-grade security-hardened OpenJDK 25 base image for Banco Pichincha. Hardened, nonroot, read-only binaries, Kyverno CA, es_EC.utf8 locale, ready for Spring Boot layering."
LABEL org.opencontainers.image.version="25"
LABEL org.opencontainers.image.vendor="Banco Pichincha"

RUN test -f /etc/timezone && \
    test -f /etc/localtime && \
    test -d /opt/build/logs && \
    curl --version >/dev/null 2>&1 && \
    sed --version >/dev/null 2>&1 && \
    test -f /usr/lib/libfreetype.so.6 && \
    test -f /usr/lib/libbz2.so.1 && \
    test -f /usr/lib/libpng16.so.16 && \
    test -f /usr/lib/libfontconfig.so.1 && \
    test -d /etc/fonts && \
    test -d /usr/share/fonts/dejavu-core && \
    test -d /usr/share/fonts/dejavu-extra && \
    test -x "$JAVA_HOME/bin/java" && \
    java -version && \
    test ! -e /usr/bin/nc && \
    test ! -e /usr/bin/su && \
    openssl version && \
    test -s /etc/ssl/openssl.cnf && \
    openssl list -providers -provider legacy -provider default >/dev/null && \
    printf 'Image built: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > /opt/.build-timestamp && \
    printf 'Image: %s\n' 'Golden Image OpenJDK 25 Hardened (Alpaquita GLIBC)' >> /opt/.build-timestamp && \
    printf 'OS: %s\n' "$(. /etc/os-release; printf '%s' "${PRETTY_NAME:-unknown}")" >> /opt/.build-timestamp && \
    printf 'Java: %s\n' "$(java -version 2>&1 | sed -n '/ version "/p')" >> /opt/.build-timestamp && \
    printf 'Java runtime: %s\n' "$(java -version 2>&1 | sed -n '/Runtime Environment/p')" >> /opt/.build-timestamp && \
    printf 'JAVA_HOME: %s\n' "$JAVA_HOME" >> /opt/.build-timestamp && \
    printf 'curl: %s\n' "$(curl --version | sed -n 1p)" >> /opt/.build-timestamp && \
    printf 'sed: %s\n' "$(sed --version | sed -n 1p)" >> /opt/.build-timestamp && \
    printf 'User: %s\n' '65532:65532' >> /opt/.build-timestamp && \
    printf 'Locale/TZ: %s / %s\n' "$LANG" "$TZ" >> /opt/.build-timestamp && \
    chmod 444 /opt/.build-timestamp && \
    test -s /opt/.build-timestamp

WORKDIR /opt/build
USER 65532:65532