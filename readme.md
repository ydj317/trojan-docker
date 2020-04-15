./acme.sh --install-cert -d sg.cuihao.work \
--cert-file /opt/cert/cert.pem \
--key-file /opt/cert/key.pem \
--ca-file /opt/cert/ca.pem \
--fullchain-file /opt/cert/fullchain.pem

./acme.sh --issue -d sg.cuihao.work -w /var/www/html


docker run -d --name hahaha --restart=always -p 80:80 -p 443:443 -v $(pwd)/config:/opt/config cuihao777/trojan