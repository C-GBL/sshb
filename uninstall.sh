#!/usr/bin/env bash
# ===========================================================================
# SSH Buddy - Uninstaller
# ===========================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

INSTALL_DIR="${HOME}/.local/bin"
SSHB_DIR="${HOME}/.sshb"
SYSTEMD_DIR="${HOME}/.config/systemd/user"

echo ""
echo -e "${BOLD}${RED}  SSH Buddy - Uninstaller${RESET}"
echo ""
echo -e "${YELLOW}This will remove sshb, its daemon, service, and all pet data.${RESET}"
echo -n "  Are you sure? (y/n): "
read -r confirm

if [[ "${confirm}" != "y" && "${confirm}" != "Y" ]]; then
    echo "  Uninstall cancelled."
    exit 0
fi

echo ""

echo -e "${GREEN}[1/5]${RESET} Stopping daemon service..."
if command -v systemctl &> /dev/null; then
    systemctl --user stop sshb.service 2>/dev/null || true
    systemctl --user disable sshb.service 2>/dev/null || true
fi

echo -e "${GREEN}[2/5]${RESET} Removing service file..."
rm -f "${SYSTEMD_DIR}/sshb.service"
if command -v systemctl &> /dev/null; then
    systemctl --user daemon-reload 2>/dev/null || true
fi

echo -e "${GREEN}[3/5]${RESET} Removing binaries..."
rm -f "${INSTALL_DIR}/sshb"
rm -f "${INSTALL_DIR}/sshb-daemon"

echo -e "${GREEN}[4/5]${RESET} Cleaning up .bashrc..."
if grep -q "SSHB-PROMPT-INTEGRATION" "${HOME}/.bashrc" 2>/dev/null; then
    sed -i '/# SSHB-PROMPT-INTEGRATION/,/# END-SSHB-PROMPT-INTEGRATION/d' "${HOME}/.bashrc"
    echo -e "  ${GREEN}Removed prompt integration from .bashrc${RESET}"
fi

echo -e "${GREEN}[5/5]${RESET} Removing pet data..."
echo -n "  Delete all pet data in ${SSHB_DIR}? (y/n): "
read -r confirm_data
if [[ "${confirm_data}" == "y" || "${confirm_data}" == "Y" ]]; then
    rm -rf "${SSHB_DIR}"
    echo -e "  ${GREEN}Pet data removed.${RESET}"
else
    echo -e "  ${YELLOW}Pet data preserved in ${SSHB_DIR}${RESET}"
fi

echo ""
echo -e "${GREEN}${BOLD}  SSH Buddy has been uninstalled.${RESET}"
echo -e "  Run ${CYAN}source ~/.bashrc${RESET} to refresh your terminal."
echo ""
