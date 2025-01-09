#!/bin/sh
# ---
# PLSPUTMEAT: /usr/bin/config.copy
# PLSOWNME: root
# PLSGRPME: root
# PLSMODME: 555
# ---


echoerr() { echo "$@" 1>&2; }
get_anything() {
	something=$(grep "$1: " "$2" | sed 1q)
	echo "${something#*"$1": }"
}

get_ignore()	{ get_anything "PLSIGNOREME"	"$1"; }
get_location()	{ get_anything "PLSPUTMEAT"	"$1"; }
get_owner()	{ get_anything "PLSOWNME"	"$1"; }
get_group()	{ get_anything "PLSGRPME"	"$1"; }
get_mod()	{ get_anything "PLSMODME"	"$1"; }
get_post()	{ get_anything "PLSRUNPOST"	"$1"; }


ignore() {
	if [ ! -f "$1" ] || [ ! -r "$1" ]; then return 1; fi
	
	ret=$(get_ignore "$1")
	[ "$ret" = "true" ] && return 0
	return 1
}

move() {
	if [ ! -f "$1" ] || [ ! -r "$1" ];
	then
		echoerr "$0: $1: Cannot read from file"
		return
	fi
	
	dest=$(get_location "$1")
	dest=$(eval "echo \"$dest\"") # Unsafe, but I'd rather use $HOME in paths
	[ "$dest" ] || {
		echoerr "$0: $1: No destination provided"
		return
	}

	[ -d "$dest" ] && {
		echoerr "$0: $1: $dest is a directory"
		return
	}
	
	cp -R "$1" "$dest" 2>/dev/null || {
		sudo -n true 2>/dev/null || echoerr "cp failed. Trying root..." 
		sudo sh -c "[ -f \"$dest\" ] && chmod +w \"$dest\" ; cp -R \"$1\" \"$dest\""
	}
	echo "$dest"
}

own() {
	owner=$(get_owner "$1")
	[ "$owner" ] || return
	[ "$(stat -c "%U" "$1")" = "$owner" ] && return
	sudo chown "$owner" "$1"
}

grp() {
	group=$(get_group "$1")
	[ "$group" ] || return
	[ "$(stat -c "%G" "$1")" = "$group" ] && return
	sudo chgrp "$group" "$1"
}

mod() {
	perm=$(get_mod "$1")
	[ "$perm" ] || return
	owner=$(stat -c "%U" "$1")
	group=$(stat -c "%G" "$1")
	if [ "$(whoami)" = "$owner" ] || ( groups | grep -q "$group" - );
	then 
		chmod "$perm" "$1"
	else
		sudo chmod "$perm" "$1"
	fi
}

run() {
	post=$(get_post "$1")
	[ "$post" ] || return
	echo "Running '$post'"
	eval "$post"
}

for file in "$@";
do
	ignore "$file" && continue

	echo "Copying '$file'..."
	target=$(move "$file")
	[ "$target" ] && { 
		printf "\033[A\033[2K%s -> %s\n" "$file" "$target"
		own "$target";
		grp "$target";
		mod "$target";
		run "$target";
	}
done
exit 0 
