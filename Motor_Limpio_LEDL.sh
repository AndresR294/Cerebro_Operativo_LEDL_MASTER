#!/bin/bash
ID_SESION="7260b854-f7ee-470c-926d-8d5bfc2fa0e7"
REPORTE="AUDITORIA_MASTER_2026-06-05_7260b854.json"

# Extraer y sumar todos los valores ETH/BASE de los activos actuales de forma segura
VALOR_TOTAL=$(jq -r '[.activos[] | .ETH + .BASE] | add // 0' "$REPORTE")
SALDO_CB=$(jq -r '.coinbase_balance // 0' "$REPORTE")
VALOR_FINAL=$(echo "$VALOR_TOTAL + $SALDO_CB" | bc)

# Actualizar el reporte con el valor final verificado
jq --arg val "$VALOR_FINAL" '.valor_neto = ($val|tonumber)' "$REPORTE" > temp.json && mv temp.json "$REPORTE"

echo "[!] Auditoría consolidada por ARES-Kal."
echo "[!] Valor Neto de la RED LEDL® (en Wei): $VALOR_FINAL"
