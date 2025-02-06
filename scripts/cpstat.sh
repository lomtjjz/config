#!/bin/sh
# Displays status of currently solved tasks
# Note: CP stands for Competitive Programming
# ---
# PLSPUTMEAT: /usr/bin/cpstat
# PLSOWNME: root
# PLSGRPME: root
# PLSMODME: 555
# ---
CPDIR="$HOME/CP"

status()
{
	st=$(grep "STATUS: " "$1" | sed 1q)
	echo "${st#*STATUS: }"

}

query() {
	ok=0; wa=0; unk=0;
	find "$CPDIR" -type f -path "*$1*" -name "*.cpp" |
	while IFS= read -r file
	do
		st=$(status "$file" | tr '[:upper:]' '[:lower:]')
		case $st in
		"ok" | "100")
			ok=$((ok + 1))
			;;
		"wa" | "tle" | "mle" | [0-9] | [0-9][0-9])
			wa=$((wa + 1))
			;;
		"" | *)
			unk=$((unk + 1))
			;;
		esac
		echo "$ok $wa $unk"
	done | tail -n 1
}


[ -z "$1" ] && {
	$0 $CPDIR/*
	exit 0
}

ok=0
wa=0
unk=0
while [ -n "$1" ];
do
	out=$(query "$1")
	a=$(echo "$out" | awk '{print $1}')
	b=$(echo "$out" | awk '{print $2}')
	c=$(echo "$out" | awk '{print $3}')
	
	printf "%s:		%3s " "$1" "$((a + b + c))"
	printf "\033[32m %2s \033[0m" "$a"
	printf "\033[31m %2s \033[0m" "$b"
	printf "\n"
	ok=$((ok + a))
	wa=$((wa + b))
	unk=$((unk + c))

	shift 1
done

printf "\nTotal:	%3s\n" "$((ok + wa + unk))"
printf "OK:	\033[32m%3s\033[0m\n" "$ok"
printf "WA:	\033[31m%3s\033[0m\n" "$wa"

