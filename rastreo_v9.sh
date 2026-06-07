#!/bin/bash
# 🧠 RASTREADOR DE HUELLAS LEDL® V9 (API V2)
API_KEY="GBP8SDX5BCAKFEZKFPZEQPSGQVJK1UJSEZ"
ADDR="0xB56700219C1caD80770147bC90cE4d749eF59b48"

echo "[*] Analizando historial de $ADDR (API V2)..."

# Nueva URL API V2
URL="https://api.basescan.org/api?module=account&action=txlist&address=$ADDR&startblock=0&endblock=99999999&sort=desc&apikey=$API_KEY"

# Ejecución y purga de errores de deprecación
RESPONSE=$(curl -s "$URL")

# Verificar si el resultado es válido o contiene el aviso de migración
if echo "$RESPONSE" | grep -q '"status":"1"'; then
    echo "[!] Historial obtenido exitosamente."
    echo "$RESPONSE" | jq -r '.result[] | {hash: .hash, to: .to, value: .value} | @text' | head -n 5
else
    echo "[!] Error en la consulta o historial vacío. Intentando modo de recuperación..."
    # Intento alternativo forzado a V2
    curl -s "https://api-base.basescan.org/api?module=account&action=txlist&address=$ADDR&sort=desc&apikey=$API_KEY" | jq -r '.result[0:5]'
fi
