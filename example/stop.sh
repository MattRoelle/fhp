#!/bin/bash
pid=$(cat ./logs/nginx.pid)
echo "killing " $pid
kill $pid
#killall nginx
