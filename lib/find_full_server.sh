#!/bin/bash
# set -euo pipefail
# IFS=$'\n\t'

if [ ! -f lib/lib.sh ]
then
    echo "Error: lib/lib.sh not found!"
    echo "make sure you are in the root of the server repo"
    exit 1
fi

source lib/lib.sh

mkdir -p lib/var/tmp

http_master_url=https://master1.ddnet.org/ddnet/15/servers.json
http_cache=lib/var/tmp/pl_connect_servers.json

mapname="$CFG_PL_CONNECT_MAP"
server_name="$CFG_PL_CONNECT_SERVER_NAME"
cmd_prefix="$CFG_PL_CONNECT_CMD_PREFIX"
cmd_prefix="${cmd_prefix%%+(;)}"
if [ "$cmd_prefix" != "" ]
then
	cmd_prefix+=';'
fi

function pl_log() {
	local msg="$1"
	ts="$(date '+%F %H:%M')"
	echo "[$ts][client-plugin-connect] $msg"
}

function dl_servers_json() {
	curl --silent "$http_master_url" > "$http_cache"
	if ! jq . "$http_cache" > /dev/null
	then
		pl_log "downloaded invalid servers.json"
		exit 1
	fi
}

function get_server_by_ip() {
	local ipaddr="$1"
	if ! [[ "$ipaddr" = 'tw-0.6+udp://'* ]]
	then
		ipaddr="tw-0.6+udp://$ipaddr"
	fi
	jq "[.servers[] | select(.addresses | index(\"$ipaddr\") ) ][0]" "$http_cache"
}

function get_fullest_server_ip() {
	local mapname="$1"
	jq -r "[.servers[] | select(.info.map.name == \"$mapname\")] | sort_by(.info.clients | length) | .[-1].addresses[0]" \
		"$http_cache" |
		cut -d'/' -f3
}

function get_fullest_server_ip_match_name() {
	local mapname="$1"
	local server_name="$2"
	if ! jq -r "[.servers[] | select( (.info.map.name == \"$mapname\") and (.info.name | contains(\"$server_name\") ) )] | sort_by(.info.clients | length) | .[-1].addresses[0]" \
		"$http_cache" |
		cut -d'/' -f3
	then
			exit 1
	fi
}

function pick_desired_ip() {
	local mapname="$1"
	local server_name="$2"
	local best_match
	if [ "$server_name" != "" ]
	then
		if ! best_match="$(get_fullest_server_ip_match_name "$mapname" "$server_name")"
		then
			exit 1
		fi
		if [ "$best_match" != "" ] && [ "$best_match" != "null" ]
		then
			echo "$best_match"
			return
		fi
	fi
	best_match="$(get_fullest_server_ip "$mapname")"
	if [ "$best_match" != "" ] && [ "$best_match" != "null" ]
	then
		echo "$best_match"
		return
	fi
	echo null
}

if ! is_cfg CFG_PL_CONNECT
then
	pl_log "plugin is off. not starting .."
	exit 0
fi

# refresh cache keep it in the beginning
dl_servers_json

server_ip="$(get_fullest_server_ip_match_name "$mapname" "$server_name")"

current_ip=
if [ -f lib/var/tmp/pl_connect_current_ip.txt ]
then
	current_ip="$(cat lib/var/tmp/pl_connect_current_ip.txt)"
fi
current_player_count=0
if [ "$current_ip" != "" ]
then
	if ! current_player_count="$(get_server_by_ip "$current_ip" | jq '.info.clients | length')"
	then
		pl_log "failed to get current player count"
	fi
fi

if [ "$server_ip" != "null" ] && [ "$server_ip" != "" ] && [ "$current_ip" != "$server_ip" ]
then
	if [ "$current_player_count" -ge "$CFG_PL_CONNECT_SWITCH_IF_LESS_THAN" ]
	then
		exit 0
	fi
	destination_name="$(get_server_by_ip "$server_ip" | jq '.info.name')"
	if ! destination_player_count="$(get_server_by_ip "$server_ip" | jq '.info.clients | length')"
	then
		get_server_by_ip "$server_ip"
		pl_log "failed to get dest player count"
	fi
	pl_log "[-] leave - players=$current_player_count ip=$current_ip"
	pl_log "[+] join  - players=$destination_player_count ip=$server_ip name=$destination_name"

	set -x
	./lib/fifo.sh "${cmd_prefix}connect $server_ip"
	set +x

	echo "$server_ip" > lib/var/tmp/pl_connect_current_ip.txt
fi

