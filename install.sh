#!/usr/bin/env bash

set -e

echo "Installing Bilbo Temp Monitor..."

# 1. Check for lm-sensors
if ! command -v sensors >/dev/null 2>&1; then
  echo "'sensors' not found. Installing lm-sensors..."

  if [ -f /etc/fedora-release ]; then
    sudo dnf install -y lm_sensors
  elif [ -f /etc/debian_version ]; then
    sudo apt install -y lm-sensors
  else
    echo "Unsupported distro. Please install 'lm-sensors' manually."
    exit 1
  fi
else
  echo "'lm-sensors' is already installed."
fi

# 2. Prompt to run sensors-detect
read -rp "Run 'sensors-detect' to configure sensors now? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  sudo sensors-detect
fi

# 2.5 Make scripts executable before linking
chmod +x btmp.sh
chmod +x launch-btmp.sh

# 3. Symlink btmp.sh to ~/.local/bin
mkdir -p ~/.local/bin
SCRIPT_PATH="$(realpath btmp.sh)"
LINK_PATH="$HOME/.local/bin/btmp.sh"

if [ -L "$LINK_PATH" ]; then
  # It's a symlink — check if it's pointing to our script
  if [ "$(readlink "$LINK_PATH")" = "$SCRIPT_PATH" ]; then
    echo "Symlink already points to this script."
  else
    echo "A symlink exists at $LINK_PATH, but points elsewhere."
    read -rp "Replace it with a symlink to this script? [y/N] " replace
    if [[ "$replace" =~ ^[Yy]$ ]]; then
      rm "$LINK_PATH"
      ln -s "$SCRIPT_PATH" "$LINK_PATH"
      echo "Replaced old symlink."
    else
      echo "Skipping symlink creation."
    fi
  fi

elif [ -e "$LINK_PATH" ]; then
  echo "A file named 'btmp.sh' already exists at ~/.local/bin"
  echo "Aborting install to avoid overwriting."
  exit 1

else
  ln -s "$SCRIPT_PATH" "$LINK_PATH"
  echo "Symlinked btmp.sh to ~/.local/bin"
fi

# 4. Add alias to shell profile
ALIAS_LINE="alias btmp='bash ~/Documents/dev/btmp/launch-btmp.sh'"
SHELL_RC="$HOME/.zshrc"
[ "$SHELL" = "/bin/bash" ] && SHELL_RC="$HOME/.bashrc"

if ! grep -Fxq "$ALIAS_LINE" "$SHELL_RC"; then
  echo "$ALIAS_LINE" >> "$SHELL_RC"
  echo "Alias 'btmp' added to $SHELL_RC"
else
  echo "Alias already exists in $SHELL_RC"
fi

# 5. Final message
echo ""
echo "Bilbo Temp Monitor installed."
echo "Run it with: btmp"
echo "Or directly: bash launch-btmp.sh"
echo ""
echo "To activate the alias now: source $SHELL_RC"
