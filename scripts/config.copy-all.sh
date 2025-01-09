#!/bin/sh
# ---
# PLSPUTMEAT: /usr/bin/config.all
# PLSOWNME: root
# PLSGRPME: root
# PLSMODME: 555
# ---

DEFAULT_DIR="$HOME/config"

DIR=$DEFAULT_DIR
[ -n "$1" ] && DIR=$1


[ -n "$2" ] && printf "\033[A"
echo "* Parsing $DIR..."

merge=1
for target in "$DIR"/*;
do
	[ -d "$target" ] && $0 "$target" "$merge"
	[ -f "$target" ] && {
		config.copy "$target"
		merge=
	}
done
