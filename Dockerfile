ARG ARCH=""
ARG NGINX_VERSION="1.23-alpine"
FROM ${ARCH}nginx:${NGINX_VERSION}

ARG STATIC_LOC=https://static.tzurl.org

ENV STATIC_LOC=${STATIC_LOC}

#COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/templates/default.conf.template /etc/nginx/templates/
COPY nginx/templates/stub_status.conf.template /etc/nginx/templates/

COPY website/index.html /usr/share/nginx/html
COPY website/images /usr/share/nginx/html/images
COPY website/zoneinfo /usr/share/nginx/html/zoneinfo
COPY website/zoneinfo-global /usr/share/nginx/html/zoneinfo-global
COPY website/zoneinfo-outlook /usr/share/nginx/html/zoneinfo-outlook
COPY website/zoneinfo-outlook-global /usr/share/nginx/html/zoneinfo-outlook-global
