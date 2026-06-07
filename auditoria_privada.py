from web3 import Web3
import json

# Nodo Infura configurado en Cerebro Operativo
w3 = Web3(Web3.HTTPProvider('https://mainnet.infura.io/v3/026aba17bbfd432bbe233e91f6181dd6'))

# Lista de direcciones del Ecosistema LEDL
direcciones = [
    "0xB56700219C1caD80770147bC90cE4d749eF59b48",
    "0x7C2ecC936613877fE854d7266ee0C5dd54a1589A",
    "0x8a153dbaec49b59bf0f4f524d209e08a4bae309d"
]

for addr in direcciones:
    checksum_addr = w3.to_checksum_address(addr)
    balance = w3.eth.get_balance(checksum_addr)
    print(f"Dirección: {addr} | Balance (ETH): {w3.from_wei(balance, 'ether')}")
