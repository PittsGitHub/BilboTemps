#!/usr/bin/env bash

# Hide cursor
tput civis

# Trap Ctrl+C or exit so we can restore cursor
trap 'tput cnorm; exit' INT TERM

# Run your dashboard
watch -n 1 -t --color ~/.local/bin/btmp.sh

# Restore cursor (in case it wasn't interrupted)
tput cnorm
