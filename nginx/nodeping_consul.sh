#!/bin/bash

#Varibles section
#
url='https://nodeping.com/content/txt/pinghosts.txt'
tmp_file=$(mktemp /tmp/nodeping.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }

#Get ip list from $url and save to temporary file $tmp_file (plus basic syntax check).
#
curl -s "$url" | awk '{print "allow " $2";" }' | grep '^allow\ [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\;$' > "$tmp_file" || { echo "Can't get file from $url"; rm -- "$tmp_file"; exit 1; }

#PUT NodePing hosts list to Consul KV.
#
curl -s -XPUT --data-binary @$tmp_file 'http://127.0.0.1:8500/v1/kv/nginx/static.mappings/nodping?token=<insert-consul-token-here>&pretty'
rm $tmp_file
