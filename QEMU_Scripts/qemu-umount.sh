#!/bin/sh
#
# umount qemu image file
#

prog=$(basename "$0")

# use sudo for unprivileged users
SUDO=
[ "$(id -u)" -ne 0 ] && SUDO=sudo

# check command line
if [ $# -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "-?" ]; then
	cat << EOF >&2
Unmount the qemu image file

Usage: $prog <qemu_image or mount_point>
EOF
	exit 1
fi

# argument
mount="$1"
full_mount=$(readlink -f "$mount")

# get the nbd device
nbd_path=$(grep -l -F -x "$full_mount" /tmp/nbd*.mount 2> /dev/null)
if [ -z "$nbd_path" ]; then
	echo "$prog: $mount not mounted"
	exit 1
fi
nbd=$(basename "$nbd_path" .mount)

# umount and detach
sync
$SUDO sh -c "mount | grep -E -o '^/dev/$nbd(\b|p[0-9]*)' | sort -u | xargs -r umount && qemu-nbd -d '/dev/$nbd'" || exit $?
rm -f "/tmp/${nbd}.mount"