#!/bin/sh
# ---
# PLSPUTMEAT: /usr/bin/updated
# PLSOWNME: root
# PLSGRPME: root
# PLSMODME: 555
# ---

wait_time=$(( 7 * 24 * 3600 ))
while true
do
	last=$(date -r /var/log/pacman.log "+%s")
	now=$(date "+%s")
	if [ "$((now - last))" -ge "$wait_time" ];
	then
		out=$(dunstify -a "Update notifier" "Honey, it's update time" -A "1, Run yay")
		[ "$out" = "1" ] && {
			nohup kitty yay -Syyu &
		}
		sleep $(( 10 * 60 ))
	else
		sleep $(( wait_time - (now - last) ))
	fi
done

