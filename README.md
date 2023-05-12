# reconnect client to fullest server

Find the fullest Multimap, blmapVX or whatever server
and auto connect to it every 5 minutes if not connected already.


        git clone git@github.com:DDNetPP/server myserver
        cd myserver/lib
        mkdir -p plugins && cd plugins
        git clone git@github.com:DDNetPP/client-plugin-connect

And then in your ``server.cnf`` put the map you want to search for


        pl_connect_map=BlmapChill
        pl_connect_server_name=
        pl_connect_switch_if_less_than=16
        pl_connect_cmd_prefix=echo hello from connect
