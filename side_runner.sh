#!/bin/bash

if [ ! -f lib/lib.sh ]
then
	echo "Error: lib/lib.sh not found!"
	echo "make sure you are in the root of the server repo"
	exit 1
fi

source lib/lib.sh

if [ -f lib/var/tmp/pl_connect_current_ip.txt ]
then
	rm lib/var/tmp/pl_connect_current_ip.txt
fi
./lib/plugins/client-plugin-connect/lib/find_full_server.sh # just for testing todo remove

echo "*** client-plugin-connect ***"
echo "starting side runner with the following config:"
echo "map=$CFG_PL_CONNECT_MAP"
echo "server_name=$CFG_PL_CONNECT_SERVER_NAME"
echo "switch_if_less=$CFG_PL_CONNECT_SWITCH_IF_LESS_THAN"
echo "cmd=$CFG_PL_CONNECT_CMD_PREFIX"

# give the client time to start
sleep 10

while true
do
	./lib/plugins/client-plugin-connect/lib/find_full_server.sh
	sleep 5m
done

