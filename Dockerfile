# PocketBase has no official Docker image. This follows the minimal Dockerfile
# from https://pocketbase.io/docs/going-to-production/ and adds a checksum check.
FROM alpine:3.22

ARG PB_VERSION=0.42.3
# PocketBase moved off GitHub in October 2026. Releases now live here.
ARG PB_DOWNLOAD=https://ganigeorgiev.com/meta/pocketbase/pocketbase/download

RUN apk add --no-cache ca-certificates unzip

WORKDIR /tmp/pb
RUN wget -q "${PB_DOWNLOAD}/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip" \
 && wget -q "${PB_DOWNLOAD}/v${PB_VERSION}/checksums.txt" \
 && grep " pocketbase_${PB_VERSION}_linux_amd64.zip\$" checksums.txt | sha256sum -c - \
 && unzip -q "pocketbase_${PB_VERSION}_linux_amd64.zip" pocketbase -d /pb \
 && rm -rf /tmp/pb

WORKDIR /pb
# Your JavaScript hooks and migrations. Both folders ship empty.
COPY pb_hooks /pb/pb_hooks
COPY pb_migrations /pb/pb_migrations

# pb_data holds the SQLite database and uploaded files. On Render it is a
# persistent disk, so it survives deploys and restarts.
VOLUME /pb/pb_data

ENV PORT=8090
EXPOSE 8090

CMD ["sh", "-c", "exec /pb/pocketbase serve --http=0.0.0.0:${PORT} --dir=/pb/pb_data --hooksDir=/pb/pb_hooks --migrationsDir=/pb/pb_migrations"]
