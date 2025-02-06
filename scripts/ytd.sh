#!/bin/sh
# Not a daemon really. Trigerred by a systemd timer once in a while
# ---
# PLSPUTMEAT: /usr/bin/ytd
# PLSOWNME: root
# PLSGRPME: root
# PLSMODME: 555
# ---

CONFIG="$HOME/.config/ytd.conf"

OUTDIR="$HOME/Videos"

URL=
LIMIT=
FLAGS=
DELETEAFTER=


# Meta format
# ID\0CHANNEL_NAME\0VIDEO_TITLE\0POSTED_AT\0REMOVED_AT\0\n

echoerr() { echo "$@" 1>&2; }

get_meta()
{
	yt-dlp	"$1" \
		-I"$2" \
		--no-cache-dir \
		--print id,timestamp,channel,title
}
download()
{
	#shellcheck disable=SC2086
	yt-dlp  "$1" \
		-I"$2" \
		--quiet \
		--no-cache-dir \
		--paths="$OUTDIR" \
		--output="%(id)s.%(ext)s" \
		$FLAGS
}


update() {
	[ "$URL" ] || {
		echoerr "err: no url provided"
		exit 1
	}
	[ "$LIMIT" ] || {
		echoerr "warn: no limit provided"
	}

	echo "Downloading from '$URL' (limit $LIMIT)"
	i=1
	while [ "$i" -le "$LIMIT" ];
	do
		META=$(get_meta "$URL" "$i")

		id=$(echo "$META"	| sed -n '1p')
		timestamp=$(echo "$META"| sed -n '2p')
		channel=$(echo "$META"	| sed -n '3p')
		title=$(echo "$META"	| sed -n '4p')
	
		grep -a -q "$id" "$OUTDIR/.meta" && break
		download "$URL" "$i" || break
		
		printf  "%s\3%s\3%s\3%s\3%s\3\n" \
			"$id" \
			"$timestamp" \
			"$channel" \
			"$title" \
			"$((timestamp + DELETEAFTER))" \
			>> "$OUTDIR/.meta"

		dunstify -t 5000 -a "ytp" "$channel" "$title"
		i=$((i + 1))
	done
}

[ -d "$OUTDIR" ] || mkdir "$OUTDIR" || exit 1
[ -f "$OUTDIR/.meta" ] || touch "$OUTDIR/.meta" || exit 1

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


now=$(date "+%s")
cp "$OUTDIR/.meta" "$OUTDIR/.meta2"
while read -r line;
do
	id=$(echo "$line" | awk -F '\3' '{ print $1 }')
	due=$(echo "$line" | awk -F '\3' '{ print $5 }')

	[ "$due" -eq "0" ] && continue
	[ "$due" -ge "$now" ] && continue

	sed -i "/^$id.*$/d" "$OUTDIR/.meta"
	printf "%s\0%s\0%s\0%s\0%s\0\n" \
		"$id" \
		"0" \
		"[DELETED]" \
		"[DELETED]" \
		"0" \
		>> "$OUTDIR/.meta"

	rm -f "$OUTDIR/$id."*
done < "$OUTDIR/.meta2"
rm "$OUTDIR/.meta2"
