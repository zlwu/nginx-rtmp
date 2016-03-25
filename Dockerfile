FROM ubuntu:14.04
MAINTAINER Reid Burke <me@reidburke.com>, Goran Stefkovski <gorans@gmail.com>, Zilong WU <zilong.wu@gmail.com>

# nginx

RUN apt-get -q -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y install cron logrotate make build-essential libssl-dev \
        zlib1g-dev libpcre3 libpcre3-dev curl pgp yasm \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y build-dep nginx \
    && apt-get -q -y clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN groupadd nginx
RUN useradd -m -g nginx nginx
RUN mkdir -p /var/log/nginx /var/cache/nginx

RUN cd /root && curl -L https://github.com/arut/nginx-rtmp-module/archive/v1.1.7.tar.gz > nginx-rtmp.tgz \
    && mkdir nginx-rtmp && tar xzf nginx-rtmp.tgz -C nginx-rtmp --strip 1 

RUN mkdir /www && cp /root/nginx-rtmp/stat.xsl /www/info.xsl && chown -R nginx:nginx /www

RUN cd /root \
    && curl -L -O http://nginx.org/download/nginx-1.9.4.tar.gz \
    && curl -L -O http://nginx.org/download/nginx-1.9.4.tar.gz.asc \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-key A1C052F8 \
    && gpg nginx-1.9.4.tar.gz.asc \
    && tar xzf nginx-1.9.4.tar.gz && cd nginx-1.9.4 \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-file-aio \
        --add-module=/root/nginx-rtmp \
        --with-ipv6 \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
   && make install


# ffmpeg

ENV     FFMPEG_VERSION=3.0 \
        YASM_VERSION=1.3.0   \
        OGG_VERSION=1.3.2    \
        VORBIS_VERSION=1.3.5 \
        THEORA_VERSION=1.1.1 \
        LAME_VERSION=3.99.5  \
        OPUS_VERSION=1.1.1   \
        FAAC_VERSION=1.28    \
        VPX_VERSION=1.5.0    \
        XVID_VERSION=1.3.4   \
        FDKAAC_VERSION=0.1.4 \
        X265_VERSION=1.9

COPY    build-ffmpeg.sh /tmp/build-ffmpeg.sh

RUN     /tmp/build-ffmpeg.sh

# system

RUN ldconfig

EXPOSE 80
EXPOSE 1935

RUN mkdir -p /etc/nginx/templates

ADD sbin/substitute-env-vars.sh /usr/sbin/substitute-env-vars.sh
ADD sbin/render-templates.sh /usr/sbin/render-templates.sh
ADD sbin/entrypoint.sh /usr/sbin/entrypoint.sh

ADD templates/nginx.conf.tmpl /etc/nginx/templates/nginx.conf.tmpl

ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf"]
