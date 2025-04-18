sensors | awk '
BEGIN {
  # 🐾 Title Header
  print "       🐾    Bilbo  -  AMD GPU watchdog reporting & borking    🐾"       
  print " ────────────────────────────────────────────────────────────────────────── "
}

# 🎨 Return block based on percentage value
function getBlockByPercentValue(percentValue) {
  if (percentValue < 15) return "🟦";
  else if (percentValue < 55) return "🟩";
  else if (percentValue < 70) return "🟨";
  else if (percentValue < 85) return "🟧";
  else return "🟥";
}

# 🎨 Get text colour value based on passed block block
function matchTextColourToBlockColour(block) {
  if (block == "🟦") return "\033[34m";      # return blue
  else if (block == "🟩") return "\033[32m"; # return green
  else if (block == "🟨") return "\033[33m"; # return yellow
  else if (block == "🟧") return "\033[33m"; # return yellow as orange value can be purple in some terminals
  else if (block == "🟥") return "\033[33m"; # return red
  else return "\033[39m" #terminal default colour
}

# 🔨 Draw the block bar based on percent value passed
function drawBarFromPct(percentValue) {
#Initially our blockBar is empty
  blockBar = ""
  totalBlocks = 20
#Now build the bar block by block until our total blocks is hit 
  for (block = 0; block < totalBlocks; block++) {
    blockInBar = block * 5
    if (blockInBar <= percentValue)
      blockBar = blockBar getBlockByPercentValue(blockInBar)
    else
      blockBar = blockBar "⬛"
  }
  #Finally we return the complete block bar
  return blockBar
}

# 🧩 Buffers block, text colour, and bar from percent value ready to be rendered
function bufferPrintComponents(percentValue, components) {
  components["block"] = getBlockByPercentValue(percentValue)
  components["color"] = matchTextColourToBlockColour(components["block"])
  components["bar"]   = drawBarFromPct(percentValue)
}

# 🖨️ Renders full output line with safe spacing
function printMetric(icon, label, unit, value, components) {
#We make sure our unit of measurment is at least 4 characters to ensure consistant styling
  minimumUnitCharacters = 4
  while (length(unit) < minimumUnitCharacters)
    unit = " " unit
  printf "  %s  %-14s %s%4d %s\033[0m   %s\n", icon, label ":", components["color"], value, unit, components["bar"]
}

# 📦 Extract values from the amdgpu section of sensors output
# If a line matching /amdgpu/ is found, begin processing the block { ... } in the text stream.
# Continue until a blank line (/^$/) is encountered, at which point the block ends.
# Note: adding +0 to each metric forces conversion to a number (not a string).
/amdgpu/, /^$/ {

   # 📈  Core Temp (Edge) — Reads and stores the core temperature
  if ($1 ~ /edge:/) {
    storedCoreTempValue = substr($2, 2, length($2) - 5) + 0
  }

  # 🔥  Hot Spot Temp (Junction) — Reads and stores the hottest point on the GPU
  else if ($1 ~ /junction:/) {
    storedJunctionTempValue = substr($2, 2, length($2) - 5) + 0
  }

  # 🧠  Memory Temp — Reads and stores the VRAM temperature
  else if ($1 ~ /mem:/) {
    storedMemoryTempValue = substr($2, 2, length($2) - 5) + 0
  }

  # ⚡  Power Drawn — Reads and stores the wattage drawn by the GPU
  else if ($1 ~ /PPT:/) {
    storedPowerDrawnValue = $2 + 0
  }

  # 🌀  Fan Speed — Reads and stores the GPU fan RPM
  else if ($1 ~ /fan1:/) {
    storedGpuFanRpmValue = $2 + 0
  }

}

END {
  #Note.
  # goes through each stored metric and prints them line by line
  # for each output we delete the components to ensure no cross contamination 

   #  📈  Core Temp Output
  delete components
  maxCoreTemp = 100
  currentCoreTempValueAsPercent = int((storedCoreTempValue / maxCoreTemp) * 100)
  bufferPrintComponents(currentCoreTempValueAsPercent, components)
  printMetric("📈", "Core Temp", "°C", int(storedCoreTempValue), components)

  #  🔥  Hot Spot Temp Output
  delete components
  maxHotSpotTemp = 110
  currentHotSpotTempValueAsPercent = int((storedJunctionTempValue / maxHotSpotTemp) * 100)
  bufferPrintComponents(currentHotSpotTempValueAsPercent, components)
  printMetric("🔥", "Hot Spot", "°C", int(storedJunctionTempValue), components)

  #  🧠  Memory Temp Output
  delete components
  maxMemoryTemp = 120
  currentMemoryTempValueAsPercent = int((storedMemoryTempValue / maxMemoryTemp) * 100)
  bufferPrintComponents(currentMemoryTempValueAsPercent, components)
  printMetric("🧠", "Memory Temp", "°C", int(storedMemoryTempValue), components)

  #  ⚡  Power Draw Output
  delete components
  maxPowerDraw = 360
  currentPowerDrawValueAsPercent = int((storedPowerDrawnValue / maxPowerDraw) * 100)
  bufferPrintComponents(currentPowerDrawValueAsPercent, components)
  printMetric("⚡", "Power Draw", "  W", storedPowerDrawnValue, components)

  #  🌀  Fan Speed Output
  delete components
  maxFanRpm = 3200
  currentFanRpmValueAsPercent = int((storedGpuFanRpmValue / maxFanRpm) * 100)
  bufferPrintComponents(currentFanRpmValueAsPercent, components)
  printMetric("🌀", "Fan Speed", "RPM", storedGpuFanRpmValue, components)

}'
