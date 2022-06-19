#!/bin/bash  
mkdir -p logs
# /usr/local/openresty/nginx/sbin/nginx -p `pwd`/ -c conf/nginx.conf
/usr/local/openresty/nginx/sbin/nginx -p `pwd`/ -c conf/nginx.conf
