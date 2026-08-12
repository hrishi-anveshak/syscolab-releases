#!/bin/sh
# SysCoLab installer — macOS / Linux.
# Usage: curl -fsSL <releases-repo-raw-url>/main/install.sh | sh
set -eu

REPO="${SYSCOLAB_RELEASES_REPO:-hrishi-anveshak/syscolab-releases}"
BIN_DIR="${SYSCOLAB_BIN_DIR:-$HOME/.local/bin}"

# ---- color, if the terminal supports it -----------------------------------
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  ACCENT="$(tput setaf 209)"; DIM="$(tput setaf 8)"; BOLD="$(tput bold)"
  OK="$(tput setaf 78)"; ERR="$(tput setaf 203)"; RESET="$(tput sgr0)"
else
  ACCENT=""; DIM=""; BOLD=""; OK=""; ERR=""; RESET=""
fi

step() { printf "%s\n" "${ACCENT}${BOLD}==>${RESET} $1"; }
ok()   { printf "%s\n" "${OK}✓${RESET} $1"; }
die()  { printf "%s\n" "${ERR}✗ $1${RESET}" >&2; exit 1; }

printf "\n"
printf "%s\n" "${ACCENT}${BOLD} S Y S C O L A B ${RESET}"
printf "%s\n\n" "${DIM}terminal ssh cockpit — by Hrishikesh Jadhav${RESET}"

# ---- detect platform --------------------------------------------------------
os="$(uname -s)"
arch="$(uname -m)"
case "$os" in
  Linux)  platform="linux" ;;
  Darwin) platform="macos" ;;
  *) die "Unsupported OS: $os (Windows: use install.ps1)" ;;
esac
case "$arch" in
  x86_64|amd64) arch="x86_64" ;;
  arm64|aarch64) arch="arm64" ;;
  *) die "Unsupported architecture: $arch" ;;
esac

asset="syscolab-${platform}-${arch}"
step "detected ${BOLD}${platform}/${arch}${RESET}"

# ---- resolve latest release --------------------------------------------------
step "looking up latest release of ${DIM}${REPO}${RESET}"
api_url="https://api.github.com/repos/${REPO}/releases/latest"
download_url="$(curl -fsSL "$api_url" | grep -o "\"browser_download_url\": *\"[^\"]*${asset}[^\"]*\"" | head -1 | sed -E 's/.*"(https:[^"]+)"/\1/')"

[ -n "$download_url" ] || die "No release asset found for ${asset}. Has a release been published to ${REPO}?"

version="$(curl -fsSL "$api_url" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"
ok "found ${BOLD}${version:-latest}${RESET}"

# ---- download ----------------------------------------------------------------
mkdir -p "$BIN_DIR"
tmp="$(mktemp)"
step "downloading"
curl -fL --progress-bar "$download_url" -o "$tmp" || die "download failed"
chmod +x "$tmp"
mv "$tmp" "$BIN_DIR/syscolab"
ok "installed to ${BIN_DIR}/syscolab"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    printf "\n%s\n" "${DIM}${BIN_DIR} is not on your PATH. Add this to your shell profile:${RESET}"
    printf "  export PATH=\"%s:\$PATH\"\n" "$BIN_DIR"
    ;;
esac

printf "\n%s\n" "${OK}${BOLD}done.${RESET} run it with: ${ACCENT}syscolab${RESET}"
printf "\n"
