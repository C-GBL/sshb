#!/usr/bin/env bash
# ===========================================================================
# SSH Buddy - Installer
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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${BOLD}${CYAN}  =====================================${RESET}"
echo -e "${BOLD}${CYAN}    SSH Buddy - Installer v2.0${RESET}"
echo -e "${BOLD}${CYAN}  =====================================${RESET}"
echo ""

echo -e "${GREEN}[1/6]${RESET} Creating directories..."
mkdir -p "${INSTALL_DIR}"
mkdir -p "${SSHB_DIR}"
mkdir -p "${SYSTEMD_DIR}"

echo -e "${GREEN}[2/6]${RESET} Installing sshb command..."
cp "${SCRIPT_DIR}/sshb" "${INSTALL_DIR}/sshb"
chmod +x "${INSTALL_DIR}/sshb"

echo -e "${GREEN}[3/6]${RESET} Installing sshb-daemon..."
cp "${SCRIPT_DIR}/sshb-daemon" "${INSTALL_DIR}/sshb-daemon"
chmod +x "${INSTALL_DIR}/sshb-daemon"

echo -e "${GREEN}[4/6]${RESET} Installing systemd user service..."
cp "${SCRIPT_DIR}/sshb.service" "${SYSTEMD_DIR}/sshb.service"

echo -e "${GREEN}[5/6]${RESET} Checking PATH..."
if [[ ":${PATH}:" != *":${INSTALL_DIR}:"* ]]; then
    local_bin_line='export PATH="${HOME}/.local/bin:${PATH}"'
    if ! grep -q '.local/bin' "${HOME}/.bashrc" 2>/dev/null; then
        echo "" >> "${HOME}/.bashrc"
        echo "# Added by sshb installer" >> "${HOME}/.bashrc"
        echo "${local_bin_line}" >> "${HOME}/.bashrc"
        echo -e "  ${YELLOW}Added ${INSTALL_DIR} to PATH in .bashrc${RESET}"
    fi
    export PATH="${INSTALL_DIR}:${PATH}"
fi

echo -e "${GREEN}[6/6]${RESET} Starting sshb daemon service..."
if command -v systemctl &> /dev/null; then
    if command -v loginctl &> /dev/null; then
        loginctl enable-linger "$(whoami)" 2>/dev/null || true
    fi
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable sshb.service 2>/dev/null || true
    systemctl --user start sshb.service 2>/dev/null || {
        echo -e "  ${YELLOW}Note: Could not start systemd service in this environment.${RESET}"
        echo -e "  ${YELLOW}The daemon will start on your next login, or run manually:${RESET}"
        echo -e "  ${YELLOW}  sshb-daemon &${RESET}"
    }
else
    echo -e "  ${YELLOW}systemctl not found. You can run the daemon manually:${RESET}"
    echo -e "  ${YELLOW}  nohup sshb-daemon &${RESET}"
fi

if [[ ! -f "${SSHB_DIR}/state" ]]; then
    sshb status > /dev/null 2>&1
fi

echo ""
echo -e "${BOLD}${GREEN}  =====================================${RESET}"
echo -e "${BOLD}${GREEN}    Installation Complete!${RESET}"
echo -e "${BOLD}${GREEN}  =====================================${RESET}"
echo ""
echo -e "  Your SSH Buddy is ready! Here is what you can do:"
echo ""
echo -e "    ${CYAN}sshb${RESET}              - See your buddy's status"
echo -e "    ${CYAN}sshb play${RESET}          - Play blackjack with your buddy"
echo -e "    ${CYAN}sshb feed${RESET}          - Feed your buddy"
echo -e "    ${CYAN}sshb interactive${RESET}   - Launch interactive mode"
echo -e "    ${CYAN}sshb help${RESET}          - See all commands"
echo ""
echo -e "  To add your buddy to your terminal prompt (with reactions):"
echo -e "    ${CYAN}sshb install-prompt${RESET}"
echo ""
echo -e "  Then run: ${CYAN}source ~/.bashrc${RESET}"
echo ""

sshb status 2>/dev/null || true
