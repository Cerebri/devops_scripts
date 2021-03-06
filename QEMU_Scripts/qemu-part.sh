#!/bin/sh
#
# show partition table of qemu image file
#

prog=$(basename "$0")

# print error message
error() {
	echo "$prog:" "$@" 2>&1
	exit 1
}

# check command line
if [ $# -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "-?" ]; then
	cat << EOF >&2
Show partition table of qemu image file

Usage: $prog qemu_image
EOF
	exit 1
fi

image="$1"

# use sudo for unprivileged users
SUDO=
[ "$(id -u)" -ne 0 ] && SUDO=sudo

# check image
[ -e "$image" ] || error "$image: no such file"
[ -f "$image" ] || error "$image must be a regular file"
img_fmt=$(qemu-img info "$image" | sed -n 's/^file format: \(.*\)/\1/p')
[ -n "$img_fmt" ] || error "$image has unknown format"

# load kernel module, check if sudo works
$SUDO modprobe nbd nbds_max=16 max_part=31 || exit $?

# lock
umask=$(umask); umask 0
(
	flock -w 5 9 || error "Can't get mount lock"
	umask "$umask"

	# find free nbd device
	nbd_size=1
	for nbd in /sys/class/block/nbd*; do
		[ -n "${nbd##*/nbd[0-9]}" ] && \
		[ -n "${nbd##*/nbd[0-9][0-9]}" ] && \
			continue
		nbd_size=$(cat "${nbd}/size")
		[ "$nbd_size" -gt 0 ] || break
	done
	[ "$nbd_size" -gt 0 ]  && error "no free nbd devices"
	nbd=$(basename "$nbd")

	# qemu-nbd
	$SUDO qemu-nbd -c "/dev/$nbd" -r -f "$img_fmt" "$image" || exit

	# show partition table
	$SUDO fdisk -l "/dev/$nbd"
	ret=$?
	sync
	$SUDO qemu-nbd -d "/dev/$nbd" > /dev/null 2>&1
	exit $ret
) 9>> /var/lock/qemu-mount.lock