sensors | awk '
BEGIN {
  print "       🐾    Bilbo  -  AMD GPU watchdog reporting & borking    🐾"       
  print " ────────────────────────────────────────────────────────────────────────── "
}

function emojiBlockByPct(p) {
  if (p < 15) return "🟦";
  else if (p < 45) return "🟩";
  else if (p < 65) return "🟨";
  else if (p < 85) return "🟧";
  else return "🟥";
}

function ansiColourFromEmoji(emoji) {
  if (emoji == "🟦") return "\033[34m";
  else if (emoji == "🟩") return "\033[32m";
  else if (emoji == "🟨") return "\033[33m";
  else if (emoji == "🟧") return "\033[33m";
  else return "\033[31m";
}

function drawBarFromPct(pct) {
  bar = ""
  for (i = 0; i < 20; i++) {
    block_pct = i * 5
    if (block_pct <= pct)
      bar = bar emojiBlockByPct(block_pct)
    else
      bar = bar "⬛"
  }
  return bar
}

/amdgpu/,/^$/ {

  if ($1 ~ /edge:/) {
    raw = substr($2, 2, length($2)-5)
    edgeTemp = raw + 0
  }

  else if ($1 ~ /junction:/) {
    raw = substr($2, 2, length($2)-5)
    junctionTemp = raw + 0
  }

  else if ($1 ~ /mem:/) {
    raw = substr($2, 2, length($2)-5)
    memTemp = raw + 0
  }

  else if ($1 ~ /PPT:/) {
    powerWatts = $2 + 0
  }

  else if ($1 ~ /fan1:/) {
    fanRpm = $2
  }
}

END {
  # Edge Temp
  pct = int((edgeTemp / 100) * 100)
  emoji = emojiBlockByPct(pct)
  color = ansiColourFromEmoji(emoji)
  bar = drawBarFromPct(pct)
  printf "  📈  Core Temp:       %s%6d°C\033[0m   %s\n", color, int(edgeTemp), bar

  # Junction Temp
  pct = int((junctionTemp / 110) * 100)
  emoji = emojiBlockByPct(pct)
  color = ansiColourFromEmoji(emoji)
  bar = drawBarFromPct(pct)
  printf "  🔥  Hot Spot:        %s%6d°C\033[0m   %s\n", color, int(junctionTemp), bar

  # Memory Temp
  pct = int((memTemp / 110) * 100)
  emoji = emojiBlockByPct(pct)
  color = ansiColourFromEmoji(emoji)
  bar = drawBarFromPct(pct)
  printf "  🧠  Memory Temp:     %s%6d°C\033[0m   %s\n", color, int(memTemp), bar

  # Power Draw
  pct = int((powerWatts / 360) * 100)
  emoji = emojiBlockByPct(pct)
  color = ansiColourFromEmoji(emoji)
  bar = drawBarFromPct(pct)
  printf "  ⚡  Power Draw:      %s%6d W\033[0m   %s\n", color, powerWatts, bar

  # Fan Speed
  rpm = fanRpm + 0
  pct = int((rpm / 3200) * 100)
  emoji = emojiBlockByPct(pct)
  color = ansiColourFromEmoji(emoji)
  bar = drawBarFromPct(pct)
  printf "  🌀  Fan Speed:     %s%6d RPM\033[0m   %s\n", color, rpm, bar
}'
