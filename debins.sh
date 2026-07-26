#!/data/data/com.termux/files/usr/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installing proot-distro and Debian${NC}"
echo -e "${GREEN}========================================${NC}"

# 1. Update packages
echo -e "${YELLOW}[1/4] Updating Termux packages...${NC}"
pkg update -y && pkg upgrade -y

# 2. Install proot-distro
echo -e "${YELLOW}[2/4] Installing proot-distro...${NC}"
pkg install -y proot-distro

# 3. Install Debian
echo -e "${YELLOW}[3/4] Installing Debian (this may take a few minutes)...${NC}"
proot-distro install debian

# 4. Verify installation
echo -e "${YELLOW}[4/4] Verifying installation...${NC}"
if proot-distro list | grep -q "debian"; then
    echo -e "${GREEN} Debian successfully installed!${NC}"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} Installation complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}To login to Debian run:${NC}"
echo -e "  proot-distro login debian"
echo -e ""
echo -e "${YELLOW}Or create an alias:${NC}"
echo -e "  echo 'alias debian=\"proot-distro login debian\"' >> ~/.bashrc"
echo -e "  source ~/.bashrc"
echo -e "${GREEN}========================================${NC}"
printf "more on https://github.com/tycon4ik"
