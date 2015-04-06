#!/bin/bash

#Populate nginx environment variables
/scripts/nginx_env.sh

#Run processes through supervisor
exec supervisord -n