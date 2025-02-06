#!/bin/sh
# A script to manage seeding linux ISOs.
# Will probably do more advanced stuff in the future
# ---
# PLSPUTMEAT: /usr/bin/torrent
# PLSOWNME: root
# PLSGRPME: root
# PLSMODME: 555
# ---


# $TORRENT_DIR layout:
# .torrents/meta		- information about files in ./.torrents/* 
# .torrents/*.torrent	- ...
# *			- downloaded/seeded data
TORRENT_DIR="$HOME/Torrents"

# $TORRENT_DIR/.torrents/meta syntax:
# FILENAME LAST_SEEN PRESENT
#
# * FILENAME  - self explanatory
# * LAST_SEEN - last time it was found by `update`
# * PRESENT   - false, if wasn't found during last `update`


clear_presence()
{
	sed -i "s/[0-9]*$/0/g" "$TORRENT_DIR/.torrents/meta"
}

update_meta()
{
	grep -q "$1" "$TORRENT_DIR/.torrents/meta" || echo "$1 0 0" >> "$TORRENT_DIR/.torrents/meta"
	sed -i "s/$1 [0-9]* [0-9]*/$1 $2 $3/" "$TORRENT_DIR/.torrents/meta"
}

update_link()
{
	echo "Getting torrents from '$1'..."
	curl -sS "$1" | grep -oE "https://[a-z0-9_\./-]*.iso.torrent" | \
	while read -r link;
	do
		file="$(basename "$link")"
		[ -f "$TORRENT_DIR/.torrents/$file" ] || {
			echo "Downloading $file..."
			curl -sS "$link" > "$TORRENT_DIR/.torrents/$file"
		}
		transmission-remote -a "$TORRENT_DIR/.torrents/$file" > /dev/null
		
		update_meta "$file" "$(date +%s)" "1"
	done
}

# Scraps pages for `*.torrent` links, downloads them and notifies the database
update()
{
	clear_presence

	update_link "https://ubuntu.com/download/alternative-downloads"

	update_link "https://torrents.artixlinux.org/torrents.php"
	update_link "https://archlinux.org/download/"
	
	update_link "https://www.linuxmint.com/edition.php?id=319"
	update_link "https://www.linuxmint.com/edition.php?id=320"
	update_link "https://www.linuxmint.com/edition.php?id=321"
}

stats()
{
	printf "Disk space used: %s\n" "$(du -sh "$TORRENT_DIR" | awk '{ print $1 }')"
	transmission-remote -st
}

# Deletes torrents that haven't been found by previous `update` call.
purge()
{
	grep -q '0$' "$TORRENT_DIR/.torrents/meta" || {
		echo "Nothing to be purged"
		exit 0
	}

	awk '{ if ($3 == 0) {print $2, $1} }' "$TORRENT_DIR/.torrents/meta" | sort | \
	awk '{ 
		cmd ="date \"+%d/%m/%Y\" -d \"@"$1"\"";
		cmd | getline var;
		printf "\033[30m%s\033[0m   %s\n", var, $2;
		close(cmd);
	}'

	printf "Purge them all? [y/N] "
	read -r ans

	[ "$ans" != "y" ] && [ "$ans" != "Y" ] && exit

	awk '{ if ($3 == 0) { print $1 }}' "$TORRENT_DIR/.torrents/meta" | \
	while read -r file;
	do
		transmission-remote -t "$file" -r > /dev/null
		sed -i "/^$file.*$/d" "$TORRENT_DIR/.torrents/meta"
	done
}

[ -d "$TORRENT_DIR" ] || mkdir "$TORRENT_DIR" || exit 1
[ -d "$TORRENT_DIR/.torrents" ] || mkdir "$TORRENT_DIR/.torrents" || exit 1
[ -f "$TORRENT_DIR/.torrents/meta" ] || touch "$TORRENT_DIR/.torrents/meta" || exit 1

case "$1" in
"update")
	update "$@"
	;;
"stats")
	stats "$@"
	;;
"purge")
	purge "$@"
	;;
""|*)
	echo "Use one of the following options:"
	echo "	update"
	echo "	stats"
	echo "	purge"
	;;
esac

