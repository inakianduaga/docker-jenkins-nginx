#!/bin/bash

#Populate nginx environment variables
/scripts/nginx_env.sh

#Jenkins prelaunch bootstrapping
/scripts/jenkins.sh

#Run processes through supervisor
exec supervisord -n