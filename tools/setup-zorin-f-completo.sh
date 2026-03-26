#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\n==> %s\n' "$1"
}

log "Updating system"
sudo apt update
sudo apt upgrade -y

log "Installing base system packages"
sudo apt install -y \
  curl \
  wget \
  git \
  vim \
  nano \
  htop \
  btop \
  fastfetch \
  unzip \
  zip \
  p7zip-full \
  ca-certificates \
  software-properties-common \
  apt-transport-https \
  ffmpeg \
  python3 \
  python3-pip \
  python3-venv \
  flatpak \
  gnome-tweaks \
  gnome-shell-extension-manager \
  gnome-software-plugin-flatpak

log "Enabling Flatpak + Flathub"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

log "Installing daily apps from Flatpak"
flatpak install -y flathub \
  com.visualstudio.code \
  md.obsidian.Obsidian \
  org.localsend.localsend_app \
  com.bitwarden.desktop \
  org.telegram.desktop \
  com.discordapp.Discord \
  com.spotify.Client \
  com.github.tchx84.Flatseal \
  com.valvesoftware.Steam \
  com.github.IsmaelMartinez.teams_for_linux \
  org.videolan.VLC

log "Installing Python CLI tools"
python3 -m pip install --user --break-system-packages \
  speedtest-cli \
  edge-tts

log "Installing Node (via nvm) for OpenClaw"
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
# shellcheck disable=SC1090
source "$NVM_DIR/nvm.sh"

nvm install --lts
nvm use --lts
npm install -g openclaw clawhub

log "Creating common folders"
mkdir -p \
  "$HOME/Apps" \
  "$HOME/Projects" \
  "$HOME/Scripts" \
  "$HOME/ISOs" \
  "$HOME/Temp"

log "Writing fastfetch config"
mkdir -p "$HOME/.config/fastfetch"
cat > "$HOME/.config/fastfetch/config.jsonc" <<'JSON'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "source": "auto",
    "padding": {
      "top": 0,
      "left": 1,
      "right": 3
    }
  },
  "display": {
    "separator": "  →  ",
    "key": {
      "color": "blue",
      "width": 12
    }
  },
  "modules": [
    {
      "type": "title",
      "color": {
        "user": "blue",
        "at": "white",
        "host": "cyan"
      }
    },
    "separator",
    { "type": "custom", "key": "OS", "format": "Zorin OS 18 Pro x86_64" },
    { "type": "host", "key": "Host" },
    { "type": "kernel", "key": "Kernel" },
    { "type": "uptime", "key": "Uptime" },
    { "type": "de", "key": "Desktop" },
    { "type": "terminal", "key": "Terminal" },
    { "type": "cpu", "key": "CPU" },
    { "type": "gpu", "key": "GPU" },
    { "type": "memory", "key": "Memory" },
    { "type": "disk", "key": "Disk" },
    { "type": "battery", "key": "Battery" }
  ]
}
JSON

log "Creating code wrapper for Flatpak VS Code"
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/code" <<'SH'
#!/usr/bin/env bash
exec flatpak run com.visualstudio.code "$@"
SH
chmod +x "$HOME/.local/bin/code"

if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

log "Installing useful VS Code extensions"
export PATH="$HOME/.local/bin:$PATH"
flatpak run com.visualstudio.code --install-extension ms-python.python || true
flatpak run com.visualstudio.code --install-extension ms-python.vscode-pylance || true
flatpak run com.visualstudio.code --install-extension ms-python.debugpy || true
flatpak run com.visualstudio.code --install-extension dbaeumer.vscode-eslint || true
flatpak run com.visualstudio.code --install-extension esbenp.prettier-vscode || true
flatpak run com.visualstudio.code --install-extension usernamehw.errorlens || true
flatpak run com.visualstudio.code --install-extension yzhang.markdown-all-in-one || true
flatpak run com.visualstudio.code --install-extension PKief.material-icon-theme || true
flatpak run com.visualstudio.code --install-extension alexshenvscode.alex-s-dark-theme || true
flatpak run com.visualstudio.code --install-extension tonybaloney.vscode-pets || true

log "Writing VS Code settings"
mkdir -p "$HOME/.var/app/com.visualstudio.code/config/Code/User"
cat > "$HOME/.var/app/com.visualstudio.code/config/Code/User/settings.json" <<'JSON'
{
  "editor.formatOnSave": true,
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1200,
  "eslint.format.enable": true,
  "eslint.run": "onType",
  "python.analysis.typeCheckingMode": "basic",
  "python.analysis.autoImportCompletions": true,
  "errorLens.enabled": true,
  "workbench.colorTheme": "Alex's Dark Theme",
  "vscode-pets.petType": "cat",
  "vscode-pets.position": "explorer",
  "[python]": {
    "editor.formatOnSave": true
  }
}
JSON

log "Final cleanup"
sudo apt autoremove -y

printf '\n==> Done.\n'
printf 'Apt was kept mostly for base system utilities; most desktop apps were installed through Flatpak.\n'
printf 'OpenClaw and ClawHub were installed, but a fresh machine still needs your own OpenClaw config/account to work exactly like this laptop.\n'
printf 'Recommended next step: reboot the laptop.\n'
