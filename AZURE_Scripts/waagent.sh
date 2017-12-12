#!/bin/sh

. /etc/rc.subr

name=waagent
waagent_flags="--daemon"

command="/usr/sbin/${name}"
command_interpreter="/usr/bin/python"

load_rc_config $name
run_rc_command "$1"