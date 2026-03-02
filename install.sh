#!/usr/bin/env bash
# ===========================================================================
# SSH Buddy - Installer
# ===========================================================================
# Installs the sshb command, daemon, and systemd service.
# Run: chmod +x install.sh && ./install.sh
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
echo -e "${BOLD}${CYAN}    SSH Buddy - Installer${RESET}"
echo -e "${BOLD}${CYAN}  =====================================${RESET}"
echo ""

# ---------------------------------------------------------------------------
# Step 1 - Create directories
# ---------------------------------------------------------------------------
echo -e "${GREEN}[1/6]${RESET} Creating directories..."
mkdir -p "${INSTALL_DIR}"
mkdir -p "${SSHB_DIR}"
mkdir -p "${SYSTEMD_DIR}"

# ---------------------------------------------------------------------------
# Step 2 - Install main binary
# ---------------------------------------------------------------------------
echo -e "${GREEN}[2/6]${RESET} Installing sshb command..."
cp "${SCRIPT_DIR}/sshb" "${INSTALL_DIR}/sshb"
chmod +x "${INSTALL_DIR}/sshb"

# ---------------------------------------------------------------------------
# Step 3 - Install daemon
# ---------------------------------------------------------------------------
echo -e "${GREEN}[3/6]${RESET} Installing sshb-daemon..."
cp "${SCRIPT_DIR}/sshb-daemon" "${INSTALL_DIR}/sshb-daemon"
chmod +x "${INSTALL_DIR}/sshb-daemon"

# ---------------------------------------------------------------------------
# Step 4 - Install systemd service
# ---------------------------------------------------------------------------
echo -e "${GREEN}[4/6]${RESET} Installing systemd user service..."
cp "${SCRIPT_DIR}/sshb.service" "${SYSTEMD_DIR}/sshb.service"

# ---------------------------------------------------------------------------
# Step 5 - Ensure PATH includes install dir
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Step 6 - Enable and start the service
# ---------------------------------------------------------------------------
echo -e "${GREEN}[6/6]${RESET} Starting sshb daemon service..."

# Check if systemd user session is available
if command -v systemctl &> /dev/null; then
    # Enable lingering so user services run even when logged out
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

# ---------------------------------------------------------------------------
# Initialize pet state if needed
# ---------------------------------------------------------------------------
if [[ ! -f "${SSHB_DIR}/state" ]]; then
    sshb status > /dev/null 2>&1
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo -e "${BOLD}${GREEN}  =====================================${RESET}"
echo -e "${BOLD}${GREEN}    Installation Complete!${RESET}"
echo -e "${BOLD}${GREEN}  =====================================${RESET}"
echo ""
echo -e "  Your SSH Buddy is ready! Here is what you can do:"
echo ""
echo -e "    ${CYAN}sshb${RESET}              - See your buddy's status"
echo -e "    ${CYAN}sshb interactive${RESET}   - Launch interactive mode"
echo -e "    ${CYAN}sshb feed${RESET}          - Feed your buddy"
echo -e "    ${CYAN}sshb play${RESET}          - Play with your buddy"
echo -e "    ${CYAN}sshb sleep${RESET}         - Put your buddy to bed"
echo -e "    ${CYAN}sshb help${RESET}          - See all commands"
echo ""
echo -e "  To add your buddy to your terminal prompt:"
echo -e "    ${CYAN}sshb install-prompt${RESET}"
echo ""
echo -e "  Then run: ${CYAN}source ~/.bashrc${RESET}"
echo ""

# Show the pet
sshb status 2>/dev/null || true
