# 编译 V2ray 最新版
# 下载 Trojan
FROM ubuntu:latest as builder

ENV TROJAN_VERSION 1.15.1

RUN apt-get update && \
    apt-get install curl -y && \
    apt-get install --no-install-recommends --no-install-suggests -y wget xz-utils && \
    wget --no-check-certificate -P /tmp https://github.com/trojan-gfw/trojan/releases/download/v${TROJAN_VERSION}/trojan-${TROJAN_VERSION}-linux-amd64.tar.xz && \
    tar xvf /tmp/trojan-${TROJAN_VERSION}-linux-amd64.tar.xz -C /tmp && \
    curl -L -o /tmp/go.sh https://install.direct/go.sh && \
    chmod +x /tmp/go.sh && \
    /tmp/go.sh

# 整合到 nginx 镜像里
FROM nginx:1.17.8

LABEL maintainer="[Trojan & V2ray & Nginx] Maintainers <cuihao871120@gmail.com>"

RUN apt-get update && \
    apt-get install curl -y && \
    apt-get install --no-install-recommends --no-install-suggests -y wget curl git && \
    git clone https://github.com/Neilpang/acme.sh.git /tmp/acme.sh && \
    cd /tmp/acme.sh && \
    chmod +x acme.sh && \
    ./acme.sh --install --force && \
    rm /tmp/acme.sh -rf

COPY --from=builder /usr/bin/v2ray/v2ray /usr/bin/v2ray/
COPY --from=builder /usr/bin/v2ray/v2ctl /usr/bin/v2ray/
COPY --from=builder /usr/bin/v2ray/geoip.dat /usr/bin/v2ray/
COPY --from=builder /usr/bin/v2ray/geosite.dat /usr/bin/v2ray/
COPY --from=builder /tmp/trojan/trojan /usr/bin/

COPY ./config/v2ray.json /opt/template/v2ray.json
COPY ./config/trojan.json /opt/template/trojan.json
COPY ./config/supervisor.conf /etc/supervisor.conf

COPY ./nginx/config/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/config/http.conf /opt/template/nginx.conf
COPY ./nginx/html/index.html /var/www/html/index.html

COPY ./cert/cert.pem /opt/cert/cert.pem
COPY ./cert/key.pem /opt/cert/key.pem

COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/bin/supervisord
COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN mkdir /var/log/v2ray/ &&\
    chmod +x /usr/bin/v2ray/v2ctl && \
    chmod +x /usr/bin/v2ray/v2ray && \
    chmod +x /usr/bin/trojan && \
    chmod +x /usr/bin/entrypoint.sh

ENV PATH /usr/bin/:/usr/bin/v2ray:$PATH

EXPOSE 80
EXPOSE 443

VOLUME ["/opt/cert", "/opt/config", "/etc/nginx/conf.d"]

CMD ["/usr/bin/entrypoint.sh"]