#!/bin/bash
# 🧠 VERIFICADOR DE LIQUIDEZ REAL LEDL® V3.1 (Migrado a API V2)
API_KEY="GBP8SDX5BCAKFEZKFPZEQPSGQVJK1UJSEZ"
USDC_CONTRACT="0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913"

echo "[*] Iniciando Escaneo Real V3.1 (USDC)..."
total_progreso=$(wc -l < LISTA_DIRECCIONES_LEDL.txt)
progreso=0

while read -r DIRECCION; do
    [[ -z "$DIRECCION" ]] && continue
    
    # Consulta V2 optimizada
    RESPONSE=$(curl -s "https://api.basescan.org/api?module=account&action=tokenbalance&contractaddress=$USDC_CONTRACT&address=$DIRECCION&tag=latest&apikey=$API_KEY")
    
    # Validación: Extraer solo números
    SALDO_CRUDO=$(echo "$RESPONSE" | jq -r '.result // 0' | tr -dc '0-9')
    if [ -z "$SALDO_CRUDO" ]; then SALDO_CRUDO=0; fi

    ((progreso++))
    porcentaje=$(( (progreso * 100) / total_progreso ))
    echo -ne "[PROGRESO: $porcentaje%] | Verificando $DIRECCION: $SALDO_CRUDO\r"
    
    if [ "$SALDO_CRUDO" -gt 0 ]; then
        echo -e "\n[!] FONDOS REALES DETECTADOS: $DIRECCION -> $SALDO_CRUDO (Unidades USDC)"
    fi
done < "LISTA_DIRECCIONES_LEDL.txt"

echo -e "\n[*] Escaneo completado. ETA: Finalizado."
