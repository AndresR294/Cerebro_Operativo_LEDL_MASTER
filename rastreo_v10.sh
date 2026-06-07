#!/bin/bash
# 🧠 RASTREADOR MULTICHAIN LEDL® V10
DIRS=("0xB56700219C1caD80770147bC90cE4d749eF59b48" "0x7C2ecC936613877fE854d7266ee0C5dd54a1589A")
NETWORKS=("https://api-optimistic.etherscan.io/api" "https://api.bscscan.com/api" "https://api.polygonscan.com/api")

echo "[*] Buscando huellas en redes externas..."

for NET in "${NETWORKS[@]}"; do
    for ADDR in "${DIRS[@]}"; do
        echo "[>] Escaneando $NET para $ADDR..."
        # Consulta de transacciones con API Key (usando la misma clave para todas las scan APIs)
        RESPONSE=$(curl -s "$NET?module=account&action=txlist&address=$ADDR&sort=desc&apikey=GBP8SDX5BCAKFEZKFPZEQPSGQVJK1UJSEZ")
        
        # Filtrar si hay transacciones
        if echo "$RESPONSE" | grep -q '"status":"1"'; then
            echo "[!!!] ACTIVIDAD ENCONTRADA en red:"
            echo "$RESPONSE" | jq -r '.result[0] | {hash: .hash, to: .to, value: .value, timeStamp: .timeStamp}'
            exit 0
        fi
    done
done
echo "[*] No se encontró actividad en las redes escaneadas."
