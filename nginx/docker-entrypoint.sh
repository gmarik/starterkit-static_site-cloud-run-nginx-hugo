#!/usr/bin/env sh
set -eu

# https://serverfault.com/a/919212
## conform to service contract https://cloud.google.com/run/docs/reference/container-contract
NGINX_PORT=${PORT:-8080}
# and set the NGINX_PORT to $PORT
sed -i "s/\${NGINX_PORT}/${NGINX_PORT}/g" /etc/nginx/conf.d/*.conf

echo "nginx: testing config"
nginx -t
echo "nginx: starting on $NGINX_PORT"

exec "$@"
