#!/bin/sh
# Youtube player (works in pair with ytd.sh)
# ---
# PLSPUTMEAT: /usr/bin/ytp
# PLSOWNME: root
# PLSGRPME: root
# PLSMODME: 555
# ---

echoerr() { echo "$@" 1>&2; }

putarr() {
	oldIFS=$IFS
	IFS='
'
	i=0
	for opt in $1;
	do
		if [ "$2" -eq "$i" ];
		then
			printf "> "
		else
			printf "  "
		fi
		printf "%s\n" "$opt"
		i=$((i+1))
	done
	IFS=$oldIFS
	unset oldIFS
}

sel=""
choose() {
	cur=0
	cnt=$(echo "$1" | wc -l)
	echo "$cnt"
	while true;
	do
		printf "\033[H\033[J"
		putarr "$1" "$cur"
		read -rs -n 1 chr
		case "$chr" in
		h | H)
			return 1
			;;
		j | J)
			cur=$((cur + 1))
			;;
		k | K)
			cur=$((cur - 1 + cnt))
			;;
		l | L)
			cur=$((cur + 1))
			sel=$(echo "$1" | sed -n "${cur}p")
			return 0
			;;
		esac
		cur=$((cur % cnt))
	done
}


TARGET="$HOME/Videos/"

menu="C"
while true;
do
	case "$menu" in
	C)
		channels=$(for file in $TARGET/*;
		do
			channel="${file#*[}"
			channel="${channel%%]*}"
			echo "$channel"
		done | sort -u)

		choose "$channels" || exit 0
		channel=$sel
		menu="V"
		;;
	V)
		vids=$(for file in $TARGET/*;
		do
			echo "$file" | grep -q "\[$channel\]" || continue
			[ "$file" = "${file%.tag}" ] || continue

			vid="${file#*[}"
			vid="${file#*] }"
			echo "$vid"
		done | sort -u)

		choose "$vids" || {
			menu="C"
			continue
		}
		mpv "$TARGET/[$channel] $sel"
		;;
	esac
done

