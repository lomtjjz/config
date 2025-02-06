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
	i=0
	echo "$1" | while IFS= read -r opt;
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

channels() {
	out=$(awk -F '\3' '{ if ($5!=0) {print $3} }' "$TARGET/.meta" | sed "/^$/d" | sort -u)

	[ -z "$out" ] && {
		echo "No videos found..."
		exit 1
	}

	while true;
	do
		choose "$out" || break
		"$0" "$sel"
	done
}

vids() {
	out=$(awk -F '\3' -v var="$1" '{ if ($5!=0 && $3==var) {print $2, $4} }' "$TARGET/.meta" | sed "/^$/d" | \
	sort -r | awk '{
                cmd ="date \"+%d/%m/%Y\" -d \"@"$1"\"";
                cmd | getline time;
		$1="";
                printf "\033[30m%s\033[0m\t%s\n", time, $0;
                close(cmd);
        }')

	[ -z "$out" ] && {
		echo "No videos found..."
		exit 1
	}

	while true;
	do
		choose "$out" || break

		name=$(echo "$sel" | awk '{ $1=""; print $0 }' | sed 's/^ //g')
		id=$(grep -a "$name" "$TARGET/.meta" | awk -F '\3' '{ print $1 }')
		mpv "$TARGET/$id."*
	done
}


TARGET="$HOME/Videos"

if [ -z "$1" ];
then channels
else vids "$1"
fi
