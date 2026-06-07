#!/bin/bash
# 🧠 AUDITORÍA INTEGRAL LEDL® V7 (Soporte V2)
API_KEY="GBP8SDX5BCAKFEZKFPZEQPSGQVJK1UJSEZ"
TOKENS=("0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913" "0xfde4C96c8593536E31F229EA8f37b2ADa2699bb2" "0x4200000000000000000000000000000000000006")
DIRS=("0xB56700219C1caD80770147bC90cE4d749eF59b48" "0x7C2ecC936613877fE854d7266ee0C5dd54a1589A" "0x8a153dbaec49b59bf0f4f524d209e08a4bae309d" "0x4162f05163de0f1d2eec2b73ba26cc325988dcb7" "0x0a06a5865dd6150151c5692d61597c4491683c24")

echo "[*] Iniciando Escaneo V7 (Modo API V2)..."

for ADDR in "${DIRS[@]}"; do
    for TKN in "${TOKENS[@]}"; do
        # Llamada a V2
        RESPONSE=$(curl -s "https://api.basescan.org/api?module=proxy&action=eth_call&to=$TKN&data=0x70a08231000000000000000000000000${ADDR#0x}&tag=latest&apikey=$API_KEY")
        
        # Extraer resultado y limpiar avisos
        SALDO_HEX=$(echo "$RESPONSE" | jq -r '.result // "0x0"' | grep -oE '^0x[0-9a-fA-F]+')
        
        if [ ! -z "$SALDO_HEX" ] && [ "$SALDO_HEX" != "0x0" ]; then
            SALDO_DEC=$(printf "%d" "$SALDO_HEX")
            echo "[!] FONDOS DETECTADOS en $ADDR -> Token $TKN: $SALDO_DEC"
        fi
    done
done
echo "[*] Auditoría finalizada."
