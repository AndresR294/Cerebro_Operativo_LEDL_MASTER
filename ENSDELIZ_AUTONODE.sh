#!/usr/bin/env bash

# =========================================
# ENSDELIZ AUTONODE v1.0 - HYBRID ENGINE
# =========================================

set -euo pipefail

LOG="$HOME/ensdeliz.log"
WORKDIR="$HOME/ensdeliz"
RETRIES=3

echo "[🚀] ENSDELIZ AUTONODE INIT" | tee -a "$LOG"

# =========================
# FUNCIONES BASE
# =========================

retry() {
  local n=0
  until [ $n -ge $RETRIES ]
  do
    "$@" && break
    n=$((n+1))
    echo "[⚠️] Retry $n/$RETRIES..." | tee -a "$LOG"
    sleep 2
  done

  if [ $n -eq $RETRIES ]; then
    echo "[❌] Failed: $*" | tee -a "$LOG"
    exit 1
  fi
}

install_pkg() {
  if ! command -v "$1" &> /dev/null; then
    echo "[📦] Installing $1..." | tee -a "$LOG"
    retry pkg install -y "$1" || retry apt install -y "$1"
  else
    echo "[✔] $1 OK" | tee -a "$LOG"
  fi
}

# =========================
# PREPARACIÓN SISTEMA
# =========================

echo "[⚙️] Updating system..." | tee -a "$LOG"
retry pkg update -y || retry apt update -y

mkdir -p "$WORKDIR"
cd "$WORKDIR"

# =========================
# DEPENDENCIAS
# =========================

for pkg in git curl jq nodejs npm; do
  install_pkg "$pkg"
done

# =========================
# IPFS SETUP
# =========================

if ! command -v ipfs &> /dev/null; then
  echo "[🌐] Installing IPFS (Kubo)..." | tee -a "$LOG"
  retry pkg install -y kubo || retry apt install -y kubo
fi

if [ ! -d "$HOME/.ipfs" ]; then
  echo "[🔧] Initializing IPFS..." | tee -a "$LOG"
  ipfs init
fi

echo "[🚀] Starting IPFS daemon..." | tee -a "$LOG"
nohup ipfs daemon > "$HOME/ipfs.log" 2>&1 &

sleep 5

# =========================
# PROYECTO SMART CONTRACT
# =========================

if [ ! -d "$WORKDIR/project" ]; then
  echo "[📁] Creating project..." | tee -a "$LOG"
  mkdir project && cd project

  retry npm init -y
  retry npm install --save-dev hardhat

  npx hardhat init || true
else
  cd "$WORKDIR/project"
fi

# =========================
# BUILD CONTRACTS
# =========================

echo "[🔨] Compiling contracts..." | tee -a "$LOG"
retry npx hardhat compile || echo "[⚠️] Compile skipped"

# =========================
# DEPLOY (SIMULADO)
# =========================

echo "[🚀] Deploying contract..." | tee -a "$LOG"

cat <<EOF > deploy.js
async function main() {
  console.log("Deploy simulation...");
}
main();
EOF

retry node deploy.js

# =========================
# IPFS UPLOAD
# =========================

echo "[📡] Uploading metadata to IPFS..." | tee -a "$LOG"

echo '{"name":"HOLA","symbol":"HOLA"}' > metadata.json

CID=$(ipfs add -q metadata.json)

echo "[✔] CID: $CID" | tee -a "$LOG"

# =========================
# HEALTH CHECK
# =========================

echo "[🧠] Running diagnostics..." | tee -a "$LOG"

ipfs id || echo "[⚠️] IPFS issue"

node -v || echo "[⚠️] Node issue"

# =========================
# AUTO-UPDATE LOOP
# =========================

echo "[♻️] Starting auto-update loop..." | tee -a "$LOG"

while true; do
  sleep 300

  echo "[🔄] Sync cycle..." | tee -a "$LOG"

  retry git pull || echo "[ℹ️] No repo linked"

  retry ipfs repo gc || true

  date >> "$LOG"
done
