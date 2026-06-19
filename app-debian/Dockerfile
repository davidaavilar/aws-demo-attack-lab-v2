FROM debian:13-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
    && rm -rf /var/lib/apt/lists/*

COPY app.sh /app/app.sh

RUN chmod +x /app/app.sh

CMD ["/app/app.sh"]