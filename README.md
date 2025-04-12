# Bilbo Temp Monitor

**Bilbo** is a lightweight, readable terminal dashboard for monitoring AMD GPU temperature, fan speed, and power draw using `sensors` and `awk` designed to be, light weight, fast and readable.

## Features

- 📈 Core, hotspot, and memory temps
- 🌀 Fan speed with visual feedback
- ⚡ Power draw monitoring

---

## Installation

### Prerequisites

- Linux (Fedora, Ubuntu, etc.)
- `lm-sensors` installed
- Font and terminal that support emojis (recommended: Kitty, Konsole)

### 1. Clone the repo

```bash
git clone https://github.com/yourusername/bilbo-temp.git
cd bilbo-temp
```

### 2. Run the installer

```bash
bash install.sh
```

### What the installer does:

- Installs `lm-sensors` (if missing)
- Offers to run `sensors-detect` (requires sudo)
- Makes sure `btmp.sh` and `launch-btmp.sh` are executable
- Symlinks `btmp.sh` to `~/.local/bin`
- Adds an alias `btmp` to your shell config pointing to `launch-btmp.sh`

> ⚠️ Only the `sensors-detect` step uses `sudo`. The rest stays entirely within your home directory. ⚠️

---

## Usage

Once installed:

```bash
btmp
```

This will launch Bilbo in your terminal and refresh every second.

Alternatively, you can run directly:

```bash
bash launch-btmp.sh
```

---

## Uninstall

To remove everything:

- Delete `~/.local/bin/btmp.sh`
- Remove the `btmp` alias from your `.zshrc` or `.bashrc`
- Optionally delete the project folder

---

## License

MIT. Make something useful, weird, or wonderful.

---

# Thanks to Bilbo
"The best pair programming jack-a-poo you could ask for"

---
