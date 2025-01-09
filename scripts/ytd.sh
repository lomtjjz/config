#!/bin/sh
# ---
# PLSPUTMEAT: /usr/bin/ytd
# PLSOWNME: root
# PLSGRPME: root
# PLSMODME: 555
# ---

CONFIG="$HOME/.config/ytd.conf"

OUTDIR="$HOME/Videos"
OUTTEMPLATE="[%(channel)s] %(title)s.%(ext)s"
SLEEP=$(( 4 * 60 * 60 ))

URL=
LIMIT=
FLAGS=
DELETEAFTER=


echoerr() { echo "$@" 1>&2; }

# ---
#
reg_new() {

	now=$(date +%s)
	for file in "$OUTDIR"/*;
	do
		[ -z "${file##*.tag}" ] && continue
		[ -f "${file}.tag" ] && continue
		
		if [ -z "$DELETEAFTER" ];
		then
			echo "6969696969" > "${file}.tag"
		else
			echo "$((now + DELETEAFTER))" > "${file}.tag"
		fi

		channel="${file%%]*}"
		channel="${channel#*[}"
		notify-send -a "ytd" "$(basename "$file")"
	done
}

reg_clean() {
	echo "Cleaning $OUTDIR..."
	now=$(date +%s)
	for file in "$OUTDIR"/*.tag;
	do
		[ "$(cat "$file")" -le "$now" ] && {
			rm "$file" "${file%.tag}"
			touch "${file%.tag}"		# Create empty file, so it won't be downloaded again by yt-dlp
			echo "6969696969" > $file	# Will fail on Wed Nov 10 07:56:09 PM CET 2190
		}
	done
}
#
# ---

# ---
#
update() {
	[ "$URL" ] || {
		echoerr "err: no url provided"
		exit 1
	}
	[ "$LIMIT" ] || {
		echoerr "warn: no limit provided"
	}
	
	echo "Downloading from <$URL>..."
	# shellcheck disable=SC2086
	yt-dlp \
		--quiet \
		--no-cache-dir \
		--paths="$OUTDIR" \
		--output="$OUTTEMPLATE" \
		--playlist-end="$LIMIT" \
		$FLAGS \
		"$URL"
	reg_new
}

parse_config() {
	while IFS="" read -r LINE || [ -n "$LINE" ];
	do
		OPT="${LINE%%=*}"
		ARG="${LINE#*=}"

		case "$OPT" in
		"URL")
			URL=$ARG
			;;
		"LIMIT")
			LIMIT=$ARG
			;;
		"FLAGS")
			FLAGS=$ARG
			;;
		"DELETEAFTER")
			DELETEAFTER=$ARG
			;;
		"END")
			update
			URL=
			LIMIT=
			FLAGS=
			DELETEAFTER=
			;;
		esac
	done < "$CONFIG"
}
#
# ---


if [ ! -f "$CONFIG" ] || [ ! -r "$CONFIG" ];
then
	echoerr "bad \$CONFIG provided"
	exit 1
fi

if [ ! -d "$OUTDIR" ];
then
	echoerr "bad \$OUTDIR provided"
	exit 1
fi

if [ ! -r "$OUTDIR" ] || [ ! -w "$OUTDIR" ];
then
	echoerr "insufficient permissions for \$OUTDIR"
	exit 1
fi

while true;
do
	parse_config
	reg_clean
	sleep "$SLEEP"
done

