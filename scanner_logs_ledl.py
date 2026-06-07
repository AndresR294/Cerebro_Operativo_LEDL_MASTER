import csv
import os
import sys

# Definición de ruta
LOG_FILE = 'historial_recuperaciones.csv'

# Animación de carga (Requisito LEDL)
def show_progress():
    print("[*] Iniciando barrido de integridad...")
    for i in range(1, 101, 20):
        print(f"[*] Progreso: {i}% [ETA: 2s]")
    print("[!] Barrido finalizado.")

def main():
    show_progress()
    if not os.path.exists(LOG_FILE):
        print(f"[ERROR] El archivo {LOG_FILE} no existe en el directorio de trabajo.")
        print(f"[INFO] Asegúrese de ejecutar este script donde se encuentre el activo de datos.")
        sys.exit(1)
        
    with open(LOG_FILE, 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            print(f'[+] Log de recuperación detectado: {row}')

if __name__ == "__main__":
    main()
