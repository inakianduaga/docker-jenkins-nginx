#!/bin/bash

#
# Populates an nginx include file with with environment variables, and includes file into main http nginx directive
# Note: When running under supervisor, these variables need to have been sourced / defined into supervisor
#

#Variable list
NGINX_VARIABLES=(
    'PLACEHOLDER1'
    'PLACEHOLDER2'
)

# We pass the following variables to the apache environment dynamically
echo "" >> /etc/nginx/envvars
for i in "${NGINX_VARIABLES[@]}"
do
  :
  # do whatever on $i
  # http://stackoverflow.com/questions/10757380/bash-variable-variables
  echo "set \$$i ${!i};" >> /etc/nginx/envvars
done
