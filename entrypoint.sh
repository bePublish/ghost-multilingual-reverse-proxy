#!/bin/sh

set -e

ALL_INSTANCES_CONF=""

if [ -n "$GHOST_INSTANCES" ]; then
  IFS=','
  for instance in $GHOST_INSTANCES; do
    instance=$(echo "$instance" | xargs)
    path=$(echo "$instance" | cut -d':' -f1)
    url=$(echo "$instance" | cut -d':' -f2-)
    INSTANCE_CONF="
      location = ${path} { return 301 ${path}/; }
      location ${path}/ {
          proxy_set_header X-Real-IP \$remote_addr; proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto https; proxy_set_header Host \$http_host; proxy_set_header X-NginX-Proxy true;
          proxy_http_version 1.1; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection 'upgrade';
          proxy_pass ${url}; proxy_redirect off;
      }"
    ALL_INSTANCES_CONF="${ALL_INSTANCES_CONF}${INSTANCE_CONF}"
  done
fi

export GHOST_INSTANCES_CONF=$ALL_INSTANCES_CONF

# Substitute the variables into the template
envsubst '$SERVER_NAME,$PORT,$GHOST_ROOT_URL,$GHOST_INSTANCES_CONF' < /etc/nginx/templates/nginx.conf.template > /etc/nginx/nginx.conf

echo "--- Generated nginx.conf ---"
cat /etc/nginx/nginx.conf
echo "--------------------------"

# Start nginx in the foreground
nginx -g 'daemon off;'
