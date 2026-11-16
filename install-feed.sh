#!/bin/sh
# =================================================================
# KhaledAli65 Enigma2 OPKG Feed Installer (Slot)
# =================================================================

FEED_NAME="khaled-slot"
FEED_URL="https://github.com/KhaledAli65/Slot/releases/download/v1.0.0"
FEED_FILE="/etc/opkg/${FEED_NAME}-feed.conf"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}====================================================${NC}"
echo -e "${GREEN}   Installing KhaledAli65 Plugins Feed (Slot)       ${NC}"
echo -e "${CYAN}====================================================${NC}"

if [ ! -d "/etc/opkg" ]; then
    echo -e "${RED}[Error] /etc/opkg directory not found! Is this Enigma2?${NC}"
    exit 1
fi

echo -e "${YELLOW}[*] Adding feed configuration to ${FEED_FILE}...${NC}"
echo "src/gz ${FEED_NAME} ${FEED_URL}" > "${FEED_FILE}"

if [ ! -f "${FEED_FILE}" ]; then
    echo -e "${RED}[Error] Failed to create ${FEED_FILE}!${NC}"
    exit 1
fi

echo -e "${YELLOW}[*] Updating OPKG feeds (opkg update)...${NC}"
opkg update

if [ $? -eq 0 ]; then
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${GREEN}[Success] KhaledAli65 Feed installed & updated!     ${NC}"
    echo -e "${GREEN}Open Plugins -> Press Green Button to download.     ${NC}"
    echo -e "${CYAN}====================================================${NC}"
else
    echo -e "${RED}[Warning] Feed added, but opkg update returned warnings.${NC}"
fi

exit 0
