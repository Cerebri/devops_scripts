#!/bin/sh

. /etc/rc.subr

name=waagent
rcvar=waagent_enable

command="/usr/sbin/${name} --daemon"

load_rc_config $name
run_rc_command "$1"