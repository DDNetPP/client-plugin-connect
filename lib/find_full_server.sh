#!/bin/bash

http_master_url=https://master1.ddnet.org/ddnet/15/servers.json

mapname=BlmapChill
if [ "$CFG_PL_CONNECT_MAP" != "" ]
then
	mapname="$CFG_PL_CONNECT_MAP"
fi

curl "$http_master_url" | jq -r "[.servers[] | select(.info.map.name == \"$mapname\")] | sort_by(.info.clients | length) | .[-1].addresses[0]" | cut -d'/' -f3

