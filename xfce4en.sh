#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Launching XFCE on Debian with stack corruption workaround ===${NC}"

# 1. Check if Debian is installed
echo -e "${YELLOW}Checking Debian installation...${NC}"
if ! proot-distro list | grep -q "debian"; then
    echo -e "${YELLOW}Debian not found. Installing...${NC}"
    proot-distro install debian
fi

# 2. Install XFCE4 in Debian (if not installed)
echo -e "${YELLOW}Checking XFCE4 installation...${NC}"
proot-distro login debian -- bash -c "
    # Check if XFCE is installed
    if ! dpkg -l | grep -q xfce4; then
        echo 'Installing XFCE4 and dependencies...'
        apt update
        apt install -y xfce4 xfce4-terminal xfce4-goodies dbus-x11 x11-utils mesa-utils
        echo 'XFCE4 installation complete!'
    else
        echo 'XFCE4 already installed'
    fi
"

# 3. Install additional useful packages
echo -e "${YELLOW}Installing additional packages...${NC}"
proot-distro login debian -- bash -c "
    apt install -y --no-install-recommends \
        firefox-esr \
        thunar \
        mousepad \
        vim \
        htop \
        neofetch \
        2>/dev/null || true
"

# 4. Hard cleanup
echo -e "${YELLOW}Cleaning processes...${NC}"
pkill -9 -f "termux-x11|Xwayland|virgl_test|pulseaudio|dbus-launch" 2>/dev/null
killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android dbus-daemon 2>/dev/null
rm -rf /tmp/.X11-unix/X0 2>/dev/null
rm -rf $TMPDIR/.X11-unix/X0 2>/dev/null
sleep 2

# 5. Start Termux:X11
echo -e "${YELLOW}Starting Termux:X11...${NC}"
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
sleep 2

# 6. Start X11 server
echo -e "${YELLOW}Starting X11 server...${NC}"
termux-x11 :0 &
sleep 3

# 7. Sound (optional)
echo -e "${YELLOW}Starting audio...${NC}"
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 2>/dev/null

# 8. Choose acceleration method
echo -e "${BLUE}┌─────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│   Select acceleration method:           │${NC}"
echo -e "${BLUE}├─────────────────────────────────────────┤${NC}"
echo -e "${BLUE}│ 1) VirGL (may work)                    │${NC}"
echo -e "${BLUE}│ 2) Turnip (for Snapdragon 6xx/7xx/8xx)│${NC}"
echo -e "${BLUE}│ 3) No acceleration (stable)            │${NC}"
echo -e "${BLUE}└─────────────────────────────────────────┘${NC}"
read -p "Your choice [1-3]: " choice

case $choice in
    1)
        echo -e "${YELLOW}Starting VirGL...${NC}"
        virgl_test_server_android &
        sleep 2
        
        echo -e "${GREEN}Launching XFCE with VirGL...${NC}"
        proot-distro login debian --shared-tmp -- bash -c "
            export DISPLAY=:0
            export PULSE_SERVER=tcp:127.0.0.1
            export GALLIUM_DRIVER=virpipe
            export MESA_GL_VERSION_OVERRIDE=3.3
            export LIBC_FATAL_STDERR_=1
            export NO_FAULT=1
            export GLIBC_TUNABLES=glibc.check=0
            export MESA_DEBUG=silent
            unset MESA_LOADER_DRIVER_OVERRIDE
            
            echo 'Starting XFCE4...'
            dbus-launch --exit-with-session startxfce4
        "
        ;;
    
    2)
        echo -e "${YELLOW}Starting Turnip...${NC}"
        # Install Vulkan drivers for Debian
        echo -e "${YELLOW}Installing Vulkan drivers...${NC}"
        proot-distro login debian -- bash -c "
            apt update
            apt install -y mesa-vulkan-drivers
        " 2>/dev/null
        
        echo -e "${GREEN}Launching XFCE with Turnip...${NC}"
        proot-distro login debian --shared-tmp -- bash -c "
            export DISPLAY=:0
            export PULSE_SERVER=tcp:127.0.0.1
            export MESA_LOADER_DRIVER_OVERRIDE=zink
            export TU_DEBUG=noconform
            export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/freedreno_icd.json
            export LIBC_FATAL_STDERR_=1
            export NO_FAULT=1
            
            echo 'Starting XFCE4...'
            dbus-launch --exit-with-session startxfce4
        "
        ;;
    
    3)
        echo -e "${YELLOW}Starting without acceleration (software rendering)...${NC}"
        echo -e "${GREEN}Launching XFCE with software rendering...${NC}"
        proot-distro login debian --shared-tmp -- bash -c "
            export DISPLAY=:0
            export PULSE_SERVER=tcp:127.0.0.1
            export LIBGL_ALWAYS_SOFTWARE=1
            export GALLIUM_DRIVER=llvmpipe
            
            echo 'Starting XFCE4...'
            dbus-launch --exit-with-session startxfce4
        "
        ;;
    
    *)
        echo -e "${RED}Invalid choice! Starting without acceleration...${NC}"
        proot-distro login debian --shared-tmp -- bash -c "
            export DISPLAY=:0
            export LIBGL_ALWAYS_SOFTWARE=1
            export GALLIUM_DRIVER=llvmpipe
            dbus-launch --exit-with-session startxfce4
        "
        ;;
esac

echo -e "${YELLOW}Cleaning up...${NC}"
pkill -9 -f "termux-x11|virgl_test" 2>/dev/null
echo -e "${GREEN}Session finished${NC}"
