FROM alpine:latest

RUN apk update && \
    apk add nginx && \
    apk add nginx-mod-rtmp && \
    apk add git && \
    apk add ffmpeg && \
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig

ENV NGINX_USER="www" \
    NGINX_UID="8987" \
    NGINX_GROUP="www" \
    NGINX_GID="8987"

RUN addgroup -g "${NGINX_GID}" "${NGINX_GROUP}" && \
    adduser -D -G "${NGINX_GROUP}" -u "$NGINX_UID" "$NGINX_USER"

RUN mkdir /www && \
    mkdir /tmp/hls && \
    chown -R "${NGINX_USER}":"${NGINX_GROUP}" /var/lib/nginx && \
    chown -R "${NGINX_USER}":"${NGINX_GROUP}" /www && \
    chown -R "${NGINX_USER}":"${NGINX_GROUP}" /tmp/hls

ADD nginx.conf /etc/nginx/nginx.conf

RUN sed -i "s/www-user/${NGINX_USER}/g" /etc/nginx/nginx.conf && \
    sed -i "s/www-group/${NGINX_GROUP}/g" /etc/nginx/nginx.conf

RUN git clone --depth 1 https://github.com/arut/nginx-rtmp-module.git /tmp/nginx-rtmp-module && \
    cp /tmp/nginx-rtmp-module/stat.xsl /etc/nginx/stat.xsl && \
    rm -rf /tmp/nginx-rtmp-module

EXPOSE 1935
EXPOSE 8935

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
