#!/bin/sh
#
# mount qemu image file into a directory
#

prog=$(basename "$0")

# use sudo for unprivileged users
SUDO=
[ "$(id -u)" -ne 0 ] && SUDO=sudo

# print error message
error() {
	echo "$prog:" "$@" 2>&1
	exit 1
}

# print usage
usage() {
	if [ $# -ge 1 ]; then
		[ -n "$*" ] && echo "$prog:" "$@" 2>&1
		echo 2>&1
	fi
	cat << EOF >&2
Mount the qemu image file into a directory.

Usage: $prog [OPTIONS] qemu_image mount_point

Options:
  -p partition_number      select, which partition to mount, default #1
  -r                       mount read-only
  -t fstype                set filesystem type
  -o mount_options         additional mount options
  -u                       set owner to current user

Without arguments it prints a list of mounted images.
EOF
	exit 1
}

# Without arguments: print mounted images
if [ $# -eq 0 ]; then
	for file in /tmp/nbd*.mount; do
		nbd=$(basename "$file" .mount)
		[ "$nbd" = "nbd*" ] && exit 0
		image=
		while read -r line; do
			if [ -z "$image" ]; then
				image="$line"
			else
				mdir="$line"
				echo "$nbd: $image -> $mdir"
				break
			fi
		done < "$file"
	done
	exit 0
fi

# parse command line
partition=1
read_only=
fstype=
mnt_options=
set_uid=
while getopts ":p:rt:o:u" opt; do
	case $opt in
	    p)	partition="$OPTARG"
		echo "$partition" | grep -q -x "[0-9][0-9]*" || \
		error "partition number must be numeric" ;;
	    r)	read_only=1 ;;
	    t)	fstype=$OPTARG ;;
	    o)	mnt_options="${mnt_options},${OPTARG}" ;;
	    u)	set_uid=1 ;;
	    \?)	usage "illegal option -- $OPTARG" ;;
	    :)	usage "option requires an argument -- $OPTARG" ;;
	esac
done
shift $((OPTIND-1))		# remove parsed options and args from $@ list
mnt_options=${mnt_options#,}

[ $# -ne 2 ] && usage "wrong number of arguments"
image="$1"
mdir="$2"

# check file types
[ -e "$image" ] || error "$image: no such file"
[ -f "$image" ] || error "$image must be a regular file"
[ -e "$mdir" ] || error "$mdir: no such directory"
[ -d "$mdir" ] || error "$mdir must be a directory"
full_image=$(readlink -f "$image")
full_mdir=$(readlink -f "$mdir")
img_fmt=$(qemu-img info "$image" | sed -n 's/^file format: \(.*\)/\1/p')
[ -n "$img_fmt" ] || error "$image has unknown format"

# load kernel module, check if sudo works
$SUDO modprobe nbd nbds_max=16 max_part=31 || exit $?

# load FAT filesystem module
$SUDO modprobe vfat 2> /dev/null

# lock
umask=$(umask); umask 0
(
	flock -w 5 9 || error "Can't get mount lock"
	umask "$umask"

	# already in use?
	grep -q -F -x "$full_image" /tmp/nbd*.mount 2> /dev/null &&
		error "$image already mounted"
	grep -q -F -x "$full_mdir" /tmp/nbd*.mount 2> /dev/null &&
		error "$mdir already in use"

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

	# reserve nbd device
	printf "%s\n%s\n" "$full_image" "$full_mdir" > "/tmp/${nbd}.mount" || exit $?

	# qemu-nbd
	$SUDO qemu-nbd -c "/dev/$nbd" -f "$img_fmt" "$full_image"
	ret=$?
	if [ $ret -ne 0 ]; then
		rm -f "/tmp/${nbd}.mount"
		exit $ret
	fi

	# mount
	nbd_dev=/dev/$nbd
	[ "$partition" -gt 0 ] && nbd_dev="${nbd_dev}p${partition}"
	options=$mnt_options
	[ -n "$read_only" ] && options="$options,ro"
	[ -n "$set_uid" ] && options="$options,uid=$(id -u),gid=$(id -g)"
	options=${options#,}
	$SUDO mount ${fstype:+-t "$fstype"} ${options:+-o "$options"} \
		"$nbd_dev" "$full_mdir"
	ret=$?
	if [ $ret -eq 0 ]; then
		echo "$prog completed, using device $nbd_dev"
	else
		sync
		$SUDO qemu-nbd -d "/dev/$nbd" > /dev/null 2>&1
		rm -f "/tmp/${nbd}.mount"
	fi
	exit $ret
) 9>> /var/lock/qemu-mount.lock