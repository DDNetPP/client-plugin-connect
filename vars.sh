#!/bin/sh

def_var 'CFG_PL_CONNECT' 'pl_connect' 'on' '(on|off|0|1)'
def_var 'CFG_PL_CONNECT_MAP' 'pl_connect_map' 'BlmapChill' ''
def_var 'CFG_PL_CONNECT_SERVER_NAME' 'pl_connect_server_name' '' ''
def_var 'CFG_PL_CONNECT_SWITCH_IF_LESS_THAN' 'pl_connect_switch_if_less_than' '16' '[0-9]+'
def_var 'CFG_PL_CONNECT_CMD_PREFIX' 'pl_connect_cmd_prefix' 'echo hello from connect' ''

