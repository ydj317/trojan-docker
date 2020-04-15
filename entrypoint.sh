#!/usr/bin/env sh

get_uuid() {
    /usr/bin/v2ray/v2ctl uuid
}

get_password() {
    /usr/bin/v2ray/v2ctl uuid | cut -d'-' -f 5
}

if [ ! -f "/opt/config/v2ray.json" ]; then
    sed "s/\${UUID}/$(get_uuid)/g" /opt/template/v2ray.json > /opt/config/v2ray.json
fi

if [ ! -f "/opt/config/trojan.json" ]; then
    sed "s/\${PASSWORD}/$(get_password)/g" /opt/template/trojan.json > /opt/config/trojan.json
fi

if [ ! -f "/opt/config/nginx.conf" ]; then
    cp /opt/template/nginx.conf /opt/config/nginx.conf
fi

/usr/bin/supervisord -c /etc/supervisor.conf