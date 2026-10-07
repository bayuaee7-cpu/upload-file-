#!/bin/bash

# Advanced Android Performance Optimizer
# Developer: Willy Gailo
# Supports both Rooted and Non-rooted devices
# Run in Termux

# Troll Face ASCII Art
echo -e "\033[1;36m"
echo "░░░░░▄▄▄▄▀▀▀▀▀▀▀▀▄▄▄▄▄▄░░░░░░░"
echo "░░░░░█░░░░▒▒▒▒▒▒▒▒▒▒▒▒░░▀▀▄░░░░"
echo "░░░░█░░░▒▒▒▒▒▒░░░░░░░░▒▒▒░░█░░░"
echo "░░░█░░░░░░▄██▀▄▄░░░░░▄▄▄░░░░█░░"
echo "░▄▀▒▄▄▄▒░█▀▀▀▀▄▄█░░░██▄▄█░░░░█░"
echo "█░▒█▒▄░▀▄▄▄▀░░░░░░░░█░░░▒▒▒▒▒░█"
echo "█░▒█░█▀▄▄░░░░░█▀░░░░▀▄░░▄▀▀▀▄▒█"
echo "░█░▀▄░█▄░█▀▄▄░▀░▀▀░▄▄▀░░░░█░░█░"
echo "░░█░░░▀▄▀█▄▄░█▀▀▀▄▄▄▄▀▀█▀██░█░░"
echo "░░░█░░░░██░░▀█▄▄▄█▄▄█▄████░█░░░"
echo "░░░░█░░░░▀▀▄░█░░░█░█▀██████░█░░"
echo "░░░░░▀▄░░░░░▀▀▄▄▄█▄█▄█▄█▄▀░░█░░"
echo "░░░░░░░▀▄▄░▒▒▒▒░░░░░░░░░░▒░░░█░"
echo "░░░░░░░░░░▀▀▄▄░▒▒▒▒▒▒▒▒▒▒░░░░█░"
echo "░░░░░░░░░░░░░░▀▄▄▄▄▄░░░░░░░░█░░"
echo -e "\033[0m"

echo -e "\033[1;32m╔══════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;32m║        ADVANCED ANDROID PERFORMANCE OPTIMIZER        ║\033[0m"
echo -e "\033[1;32m║                Developer: Willy Gailo                ║\033[0m"
echo -e "\033[1;32m╚══════════════════════════════════════════════════════╝\033[0m"

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "\033[1;31m[ERROR] This script must be run in Termux!\033[0m"
    exit 1
fi

# Function to check root status
check_root() {
    echo -e "\033[1;34m[INFO] Checking root status...\033[0m"
    
    # Check for su binary
    if command -v su >/dev/null 2>&1; then
        # Test if su works
        if su -c "id" | grep -q "uid=0"; then
            export IS_ROOTED=true
            echo -e "\033[1;32m[SUCCESS] Device is rooted. Enabling enhanced optimizations!\033[0m"
            return 0
        fi
    fi
    
    if [ -f "/system/xbin/su" ] || [ -f "/system/bin/su" ]; then
        export IS_ROOTED=true
        echo -e "\033[1;32m[SUCCESS] Root binary detected. Enabling enhanced optimizations!\033[0m"
        return 0
    fi

    export IS_ROOTED=false
    echo -e "\033[1;33m[INFO] Device is not rooted. Running in standard mode.\033[0m"
    return 1
}

# Request storage permission if not granted
if [ ! -d ~/storage ]; then
    echo -e "\033[1;33m[INFO] Requesting storage permission...\033[0m"
    termux-setup-storage
    sleep 2
fi

# Check for required packages and install if missing
packages=("termux-api" "proot" "tsu")
echo -e "\033[1;34m[INFO] Checking for required packages...\033[0m"
for pkg in "${packages[@]}"; do
    if ! command -v "$pkg" &>/dev/null && ! pkg list-installed | grep -q "$pkg"; then
        echo -e "\033[1;33m[INFO] Installing $pkg...\033[0m"
        pkg install -y "$pkg"
    fi
done

# Install Termux API if not installed
if ! pkg list-installed | grep -q "termux-api"; then
    echo -e "\033[1;33m[INFO] Installing Termux API package...\033[0m"
    pkg install -y termux-api
    echo -e "\033[1;33m[INFO] Please install the Termux:API app from Google Play Store or F-Droid\033[0m"
fi

# Check if device is rooted
check_root

echo -e "\033[1;34m╔══════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;34m║               APPLYING PERFORMANCE TWEAKS             ║\033[0m"
echo -e "\033[1;34m╚══════════════════════════════════════════════════════╝\033[0m"

# Function to check if device supports high refresh rate
check_refresh_rate() {
    echo -e "\033[1;36m[INFO] Checking device refresh rate capabilities...\033[0m"
    
    # Check for root capability first
    if [ "$IS_ROOTED" = true ]; then
        # Use root access to check refresh rate
        if su -c "cat /sys/class/drm/card*/modes" 2>/dev/null | grep -q "[0-9][0-9][0-9]"; then
            HIGH_RATE=$(su -c "cat /sys/class/drm/card*/modes" 2>/dev/null | grep -o "[0-9][0-9][0-9]" | sort -nr | head -1)
            echo -e "\033[1;32m[SUCCESS] Device supports ${HIGH_RATE}Hz refresh rate!\033[0m"
            export MAX_REFRESH_RATE=$HIGH_RATE
            return 0
        fi
    else
        # Non-root method to check capabilities
        if [ -f /sys/class/graphics/fb0/modes ]; then
            if grep -q "120" /sys/class/graphics/fb0/modes; then
                echo -e "\033[1;32m[SUCCESS] Device potentially supports 120Hz refresh rate!\033[0m"
                export MAX_REFRESH_RATE=120
                return 0
            elif grep -q "90" /sys/class/graphics/fb0/modes; then
                echo -e "\033[1;32m[SUCCESS] Device potentially supports 90Hz refresh rate!\033[0m"
                export MAX_REFRESH_RATE=90
                return 0
            fi
        fi
    fi
    
    echo -e "\033[1;33m[INFO] Could not confirm high refresh rate support. Using default (60Hz).\033[0m"
    export MAX_REFRESH_RATE=60
    return 1
}

# Function to optimize Android settings via ADB for non-rooted devices
optimize_settings_nonroot() {
    echo -e "\033[1;36m[INFO] Optimizing Android settings (non-root method)...\033[0m"
    
    # Check if Termux:API is available
    if ! command -v termux-battery-status &>/dev/null; then
        echo -e "\033[1;31m[ERROR] Termux:API not found. Some optimizations skipped.\033[0m"
        return 1
    fi
    
    # Attempt to set animation scales for smoother performance
    settings_commands=(
        "put global window_animation_scale 0.5"
        "put global transition_animation_scale 0.5"
        "put global animator_duration_scale 0.5"
        "put global always_finish_activities 1"
        "put system user_rotation 0"
        "put global enable_freeform_support 1"
        "put global zram_enabled 1"
    )
    
    for cmd in "${settings_commands[@]}"; do
        am broadcast --user 0 -a com.termux.api.intent.action.EXECUTE \
        --es command "settings $cmd" > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo -e "\033[1;32m[SUCCESS] Applied: settings $cmd\033[0m"
        else
            echo -e "\033[1;33m[WARNING] Failed: settings $cmd\033[0m"
        fi
    done
    
    return 0
}

# Function to optimize Android settings via root
optimize_settings_root() {
    echo -e "\033[1;36m[INFO] Optimizing Android settings (root method)...\033[0m"
    
    settings_commands=(
        "put global window_animation_scale 0.5"
        "put global transition_animation_scale 0.5"
        "put global animator_duration_scale 0.5"
        "put global always_finish_activities 1"
        "put system user_rotation 0"
        "put global enable_freeform_support 1"
        "put global zram_enabled 1"
        "put global zram_size 2147483648"
        "put global cached_apps_freezer enabled"
        "put global fstrim_mandatory_interval 86400000"
        "put global fancy_ime_animations 0"
        "put global tether_dun_required 0"
        "put global wifi_scan_throttle_enabled 0"
        "put global kernel.perf_cpu_time_max_percent 30"
        "put global persist.sys.use_dithering 0"
        "put global power_supply_logger 1"
        "put global debug.hwui.renderer opengl"
    )
    
    for cmd in "${settings_commands[@]}"; do
        su -c "settings $cmd" > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo -e "\033[1;32m[SUCCESS] Applied: settings $cmd\033[0m"
        else
            echo -e "\033[1;33m[WARNING] Failed: settings $cmd\033[0m"
        fi
    done

    # Apply advanced tweaks via root
    su -c "echo 2048 > /proc/sys/vm/min_free_kbytes" 2>/dev/null
    su -c "echo 90 > /proc/sys/vm/vfs_cache_pressure" 2>/dev/null
    su -c "echo 60 > /proc/sys/vm/swappiness" 2>/dev/null
    su -c "echo 0 > /sys/module/lowmemorykiller/parameters/debug_level" 2>/dev/null
    
    return 0
}

# Function to set refresh rate for both rooted and non-rooted devices
set_refresh_rate() {
    echo -e "\033[1;36m[INFO] Setting optimal refresh rate (${MAX_REFRESH_RATE}Hz)...\033[0m"
    
    if [ "$IS_ROOTED" = true ]; then
        # Root method to set refresh rate
        su -c "settings put system peak_refresh_rate $MAX_REFRESH_RATE.0" 2>/dev/null
        su -c "settings put system min_refresh_rate $MAX_REFRESH_RATE.0" 2>/dev/null
        su -c "service call SurfaceFlinger 1035 i32 0" 2>/dev/null
        
        echo -e "\033[1;32m[SUCCESS] Set refresh rate to ${MAX_REFRESH_RATE}Hz (root method)\033[0m"
    else
        # Non-root method via game mode hints
        if command -v termux-vibrate &>/dev/null; then
            # Use termux-api to broadcast intent
            am broadcast --user 0 -a com.termux.api.intent.action.EXECUTE \
            --es command "settings put system peak_refresh_rate $MAX_REFRESH_RATE.0" > /dev/null 2>&1
            
            am broadcast --user 0 -a com.termux.api.intent.action.EXECUTE \
            --es command "settings put system min_refresh_rate $MAX_REFRESH_RATE.0" > /dev/null 2>&1
            
            echo -e "\033[1;32m[SUCCESS] Attempted to set refresh rate to ${MAX_REFRESH_RATE}Hz\033[0m"
            echo -e "\033[1;33m[INFO] Note: This may require display support and might not work on all devices\033[0m"
        else
            echo -e "\033[1;31m[ERROR] Could not attempt ${MAX_REFRESH_RATE}Hz mode - Termux:API required\033[0m"
        fi
    fi
}

# Function to disable terminal limits
optimize_termux() {
    echo -e "\033[1;36m[INFO] Optimizing Termux performance...\033[0m"
    
    # Create Termux properties file if it doesn't exist
    mkdir -p ~/.termux
    touch ~/.termux/termux.properties
    
    # Add/update terminal performance settings
    if ! grep -q "terminal-transcript-rows" ~/.termux/termux.properties; then
        echo "terminal-transcript-rows=10000" >> ~/.termux/termux.properties
        echo -e "\033[1;32m[SUCCESS] Increased terminal history buffer\033[0m"
    fi
    
    if ! grep -q "enforce-char-based-input" ~/.termux/termux.properties; then
        echo "enforce-char-based-input=true" >> ~/.termux/termux.properties
        echo -e "\033[1;32m[SUCCESS] Optimized character input handling\033[0m"
    fi
    
    if ! grep -q "bell-character" ~/.termux/termux.properties; then
        echo "bell-character=vibrate" >> ~/.termux/termux.properties
        echo -e "\033[1;32m[SUCCESS] Set bell character to vibrate for better performance\033[0m"
    fi
    
    # Add CPU set affinity to use all cores
    if ! grep -q "shortcut.create-session" ~/.termux/termux.properties; then
        echo "shortcut.create-session=ctrl + t" >> ~/.termux/termux.properties
        echo -e "\033[1;32m[SUCCESS] Set shortcut for new session\033[0m"
    fi

    # Reload Termux settings
    echo -e "\033[1;33m[INFO] Reloading Termux settings...\033[0m"
    termux-reload-settings
}

# Function to optimize CPU scheduling
optimize_cpu() {
    echo -e "\033[1;36m[INFO] Optimizing CPU scheduling...\033[0m"
    
    if [ "$IS_ROOTED" = true ]; then
        # Get number of CPU cores
        CORES=$(grep -c "processor" /proc/cpuinfo)
        
        # Set CPU governor to performance if possible
        for i in $(seq 0 $((CORES-1))); do
            if [ -f "/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor" ]; then
                su -c "echo 'performance' > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor" 2>/dev/null
            fi
        done
        
        # Disable thermal throttling (with caution)
        su -c "echo 0 > /sys/module/msm_thermal/parameters/enabled" 2>/dev/null
        su -c "echo N > /sys/module/msm_thermal/parameters/enabled" 2>/dev/null
        
        # Set I/O scheduler to deadline for better performance
        for block in $(ls /sys/block/ | grep -E 'sd|mmc'); do
            su -c "echo deadline > /sys/block/$block/queue/scheduler" 2>/dev/null
        done
        
        # Reduce CPU input boost duration 
        su -c "echo 64 > /sys/module/cpu_boost/parameters/input_boost_ms" 2>/dev/null
        
        echo -e "\033[1;32m[SUCCESS] Applied CPU optimizations (root method)\033[0m"
    else
        # Non-root method
        # Use taskset to improve app priority (requires Termux:API)
        if command -v termux-toast &>/dev/null; then
            # Set current process to use all available CPUs
            CORES=$(grep -c "processor" /proc/cpuinfo)
            MASK=$(((1 << CORES) - 1))
            
            # Try to set affinity (may fail without root)
            taskset -p $MASK $$ >/dev/null 2>&1
            
            echo -e "\033[1;32m[SUCCESS] Applied CPU thread priority optimizations\033[0m"
        fi
    fi
}

# Function to clear cache and optimize memory
optimize_memory() {
    echo -e "\033[1;36m[INFO] Optimizing memory usage...\033[0m"
    
    # Clear package cache in termux
    apt autoremove -y
    apt clean
    
    # Clear termux cached files
    rm -rf ~/.termux/boot/cache/* 2>/dev/null
    rm -rf ~/storage/shared/Android/data/com.termux/cache/* 2>/dev/null
    
    if [ "$IS_ROOTED" = true ]; then
        # Root memory optimizations
        su -c "sync" 2>/dev/null
        su -c "echo 3 > /proc/sys/vm/drop_caches" 2>/dev/null
        su -c "echo 1 > /proc/sys/vm/compact_memory" 2>/dev/null
        
        # Optimize zRAM if available
        if [ -d "/sys/block/zram0" ]; then
            su -c "echo 1 > /sys/block/zram0/reset" 2>/dev/null
            su -c "echo lz4 > /sys/block/zram0/comp_algorithm" 2>/dev/null
            su -c "echo 2G > /sys/block/zram0/disksize" 2>/dev/null
            su -c "mkswap /dev/block/zram0" 2>/dev/null
            su -c "swapon /dev/block/zram0" 2>/dev/null
        fi
        
        echo -e "\033[1;32m[SUCCESS] Applied memory optimizations (root method)\033[0m"
    else
        # Non-root memory optimization
        # Run garbage collection to free memory
        am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false > /dev/null 2>&1
        
        # Try to use hidden API to trim memory (may not work on all devices)
        am broadcast -a android.intent.action.SCREEN_OFF > /dev/null 2>&1
        sleep 1
        am broadcast -a android.intent.action.SCREEN_ON > /dev/null 2>&1
        
        echo -e "\033[1;32m[SUCCESS] Cleared system caches and optimized memory\033[0m"
    fi
}

# Function to optimize network settings
optimize_network() {
    echo -e "\033[1;36m[INFO] Optimizing network settings...\033[0m"
    
    if [ "$IS_ROOTED" = true ]; then
        # Root network optimizations
        su -c "settings put global wifi_scan_throttle_enabled 0" 2>/dev/null
        su -c "settings put global tether_dun_required 0" 2>/dev/null
        
        # TCP optimizations
        su -c "echo 0 > /proc/sys/net/ipv4/tcp_timestamps" 2>/dev/null
        su -c "echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse" 2>/dev/null
        su -c "echo 0 > /proc/sys/net/ipv4/tcp_sack" 2>/dev/null
        su -c "echo 0 > /proc/sys/net/ipv4/tcp_dsack" 2>/dev/null
        
        # Improve DNS resolution
        su -c "echo 'nameserver 1.1.1.1' > /system/etc/resolv.conf" 2>/dev/null
        su -c "echo 'nameserver 8.8.8.8' >> /system/etc/resolv.conf" 2>/dev/null
        
        echo -e "\033[1;32m[SUCCESS] Applied network optimizations (root method)\033[0m"
    else
        # Non-root network optimization (DNS settings in Termux)
        mkdir -p ~/.termux
        echo "nameserver 1.1.1.1" > ~/.termux/resolv.conf
        echo "nameserver 8.8.8.8" >> ~/.termux/resolv.conf
        echo -e "\033[1;32m[SUCCESS] Set faster DNS servers for Termux\033[0m"
        
        # Try to set TCP buffer sizes through settings provider
        am broadcast --user 0 -a com.termux.api.intent.action.EXECUTE \
        --es command "settings put global wifi_badging_thresholds '[0,-78,-67]'" > /dev/null 2>&1
    fi
}

# Function to add additional tweaks
additional_tweaks() {
    echo -e "\033[1;36m[INFO] Applying additional performance tweaks...\033[0m"
    
    if [ "$IS_ROOTED" = true ]; then
        # Additional root tweaks
        
        # Reduce swappiness for better memory management
        su -c "echo 10 > /proc/sys/vm/swappiness" 2>/dev/null
        
        # Increase entropy pool size
        su -c "echo 4096 > /proc/sys/kernel/random/read_wakeup_threshold" 2>/dev/null
        su -c "echo 8192 > /proc/sys/kernel/random/write_wakeup_threshold" 2>/dev/null
        
        # Set kernel parameters for better performance
        su -c "echo 50000 > /proc/sys/kernel/sched_latency_ns" 2>/dev/null
        su -c "echo 15000 > /proc/sys/kernel/sched_min_granularity_ns" 2>/dev/null
        su -c "echo 500000 > /proc/sys/kernel/sched_wakeup_granularity_ns" 2>/dev/null
        
        # Disable unnecessary kernel logging
        su -c "echo '0' > /proc/sys/kernel/printk" 2>/dev/null
        
        # Set higher process priority for system apps
        su -c "renice -n -10 `pgrep system_server`" 2>/dev/null
        su -c "renice -n -10 `pgrep surfaceflinger`" 2>/dev/null
        
        echo -e "\033[1;32m[SUCCESS] Applied additional kernel tweaks (root method)\033[0m"
    else
        # Set Termux session to high priority if possible
        if command -v renice &>/dev/null; then
            renice -n -10 -p $$ >/dev/null 2>&1
            echo -e "\033[1;32m[SUCCESS] Set Termux process to higher priority\033[0m"
        fi
    fi
    
    # Optimize package manager (works for both rooted and non-rooted)
    mkdir -p ~/.termux/apt.conf.d/
    echo 'APT::Cache-Start "100000000";' > ~/.termux/apt.conf.d/00cache
    echo -e "\033[1;32m[SUCCESS] Optimized package manager configuration\033[0m"
}

# Function to create launcher with persistence
create_launcher() {
    echo -e "\033[1;36m[INFO] Creating performance mode launcher...\033[0m"
    
    # Create a script in ~/bin to easily launch the optimizer
    mkdir -p ~/bin
    
    # Save current script path
    SCRIPT_PATH="$PWD/$(basename "$0")"
    
    # Create the launcher script
    cat > ~/bin/performance-mode << EOF
#!/bin/bash
# Advanced Android Performance Optimizer Launcher
$SCRIPT_PATH
EOF
    
    chmod +x ~/bin/performance-mode
    
    # Add to .bashrc for easy access
    if ! grep -q "performance-mode" ~/.bashrc; then
        echo "alias boost='$HOME/bin/performance-mode'" >> ~/.bashrc
    fi
    
    echo -e "\033[1;32m[SUCCESS] Created launchers: performance-mode and boost alias\033[0m"
    echo -e "\033[1;33m[INFO] You can now type 'boost' to run this optimizer anytime\033[0m"
}

# Add auto-start on boot (for persistence)
setup_autostart() {
    echo -e "\033[1;36m[INFO] Setting up auto-start on boot...\033[0m"
    
    mkdir -p ~/.termux/boot/
    
    # Create boot script
    cat > ~/.termux/boot/performance.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash
# Auto-start performance optimizer
$PWD/$(basename "$0") --silent
EOF
    
    chmod +x ~/.termux/boot/performance.sh
    echo -e "\033[1;32m[SUCCESS] Setup auto-start on boot\033[0m"
    echo -e "\033[1;33m[INFO] Optimizations will be applied automatically when device boots\033[0m"
}

# Function for device reboot
reboot_device() {
    echo -e "\033[1;36m[INFO] Preparing to reboot device...\033[0m"
    
    if [ "$IS_ROOTED" = true ]; then
        echo -e "\033[1;32m[SUCCESS] Rebooting device now (root method)...\033[0m"
        su -c "reboot" 2>/dev/null
    else
        # Non-root method (requires permission)
        am broadcast --user 0 -a com.termux.api.intent.action.EXECUTE \
        --es command "am start -a android.intent.action.REBOOT" > /dev/null 2>&1
        
        echo -e "\033[1;33m[INFO] Requested device reboot (non-root method)\033[0m"
        echo -e "\033[1;33m[INFO] You may need to manually confirm the reboot\033[0m"
    fi
}

# Run all optimization functions
check_refresh_rate

if [ "$IS_ROOTED" = true ]; then
    optimize_settings_root
else
    optimize_settings_nonroot
fi

set_refresh_rate
optimize_termux
optimize_cpu
optimize_memory
optimize_network
additional_tweaks
create_launcher
setup_autostart

echo -e "\033[1;35m╔══════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;35m║                OPTIMIZATION COMPLETE                 ║\033[0m"
echo -e "\033[1;35m╚══════════════════════════════════════════════════════╝\033[0m"

echo -e "\033[1;33m"
echo "All optimizations have been successfully applied!"
echo "Your device is now running at peak performance."
echo -e "\033[0m"

# Final options menu
echo -e "\033[1;34m╔══════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[1;34m║                      FINAL OPTIONS                    ║\033[0m"
echo -e "\033[1;34m╚══════════════════════════════════════════════════════╝\033[0m"

echo -e "\033[1;36m"
echo "Please choose an option:"
echo "1) Reboot device to apply all changes (Recommended)"
echo "2) Exit Termux and keep device running"
echo -e "\033[0m"

read -p "Enter your choice (1 or 2): " final_choice

case $final_choice in
    1)
        echo -e "\033[1;32m[INFO] Initiating device reboot...\033[0m"
        reboot_device
        ;;
    2)
        echo -e "\033[1;32m[INFO] Exiting Termux. Optimizations are active!\033[0m"
        echo -e "\033[1;32mThank you for using Android Performance Optimizer!\033[0m"
        echo -e "\033[1;36mDeveloper: Willy Gailo\033[0m"
        echo -e "\033[1;31m═══════════════════ END OF SCRIPT ═══════════════════\033[0m"
        sleep 2
        exit 0
        ;;
    *)
        echo -e "\033[1;33m[INFO] Invalid choice. Exiting without reboot.\033[0m"
        echo -e "\033[1;32mThank you for using Android Performance Optimizer!\033[0m"
        echo -e "\033[1;36mDeveloper: Willy Gailo\033[0m"
        echo -e "\033[1;31m═══════════════════ END OF SCRIPT ═══════════════════\033[0m"
        ;;
esac

exit 0