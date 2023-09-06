FROM node:18-alpine
RUN apk --no-cache add bash git curl && npm install -g semver

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
