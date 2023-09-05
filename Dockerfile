FROM alpine:3.14
RUN apk --no-cache add bash git curl && npm install -g semver

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
