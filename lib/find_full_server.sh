#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

http_master_url=https://master1.ddnet.org/ddnet/15/servers.json

mapname="$CFG_PL_CONNECT_MAP"
cmd_prefix="$CFG_PL_CONNECT_CMD_PREFIX"
cmd_prefix="$(echo "$cmd_prefix" | sed 's/;*$//')"
if [ "$cmd_prefix" != "" ]
then
	cmd_prefix+=';'
fi

function get_fullest_server_ip() {
	local mapname="$1"
	curl --silent "$http_master_url" |
		jq -r "[.servers[] | select(.info.map.name == \"$mapname\")] | sort_by(.info.clients | length) | .[-1].addresses[0]" |
		cut -d'/' -f3
}

server_ip="$(get_fullest_server_ip "$mapname")"

current_ip=
if [ -f lib/var/tmp/pl_connect_current_ip.txt ]
then
	current_ip="$(cat lib/var/tmp/pl_connect_current_ip.txt)"
fi

if [ "$server_ip" != "null" ] && [ "$server_ip" != "" ] && [ "$current_ip" != "$server_ip" ]
then
	ts="$(date '+%F %H:%M')"
	echo "[$ts][client-plugin-connect] map=$mapname connecting to '$server_ip' ..."

	./lib/fifo.sh "${cmd_prefix}connect $server_ip"

	mkdir -p lib/var/tmp
	echo "$server_ip" > lib/var/tmp/pl_connect_current_ip.txt
fi

