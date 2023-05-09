#!/bin/bash

if [ ! -f lib/lib.sh ]
then
	echo "Error: lib/lib.sh not found!"
	echo "make sure you are in the root of the server repo"
	exit 1
fi

source lib/lib.sh

while true
do
	./lib/plugins/client-plugin-connect/find_full_server.sh
	sleep 5m
done

