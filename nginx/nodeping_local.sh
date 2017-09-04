#!/bin/bash

#####
#This script gets nodeping ip addresses list from $url and adds puts it to $dst_file (for use in basic_auth.conf as include).
#####

#Varibles section
#
url='https://nodeping.com/content/txt/pinghosts.txt'
tmp_file=$(mktemp /tmp/nodeping.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }
dst_file='/etc/nginx/conf.d/nodeping_ip.conf'

#Make sure $dst_file exist. Used in nginx config and MUST be present.
#
touch "$dst_file"

#Get ip list from $url and save to temporary file $tmp_file. (plus basic syntax check)
#
curl -s "$url" | awk '{print "allow " $2";" }' | grep '^allow\ [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\;$' > "$tmp_file" || { echo "Can't get file from $url"; rm -- "$tmp_file"; exit 1; }

#Move actual nodeping IP list to $dst_file
#
if [[ -e "$tmp_file" ]]; then
    if [[ -d "/etc/nginx/conf.d" ]]; then
        mv -f -- "$tmp_file" "$dst_file"
        nginx -t && service nginx reload
    fi
else
    { echo "Can't add $dst_file, no src file $tmp_file"; exit 1; }
fi
