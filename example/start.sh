#!/bin/bash
set -e
set -x

while [ ! -f conf/nginx.conf ]; do
    cd ..
done


mkdir -p logs
if [[ -n $(which nginx) ]]; then
    nginx -p `pwd`/ -c conf/nginx.conf
elif [[ -n $(which openresty) ]]; then
    openresty -p `pwd`/ -c conf/nginx.conf
else
    /opt/homebrew/Cellar/openresty/1.21.4.2_1/nginx/sbin/nginx -p `pwd`/ -c conf/nginx.conf
fi

set +x
echo "nginx server started on http://localhost:8080"
