#!/bin/bash
# adb-tunnel.sh — pokretati na LAPTOPU (Pop!_OS)
# Otvara reverse SSH tunel: VPS:5555 → telefon:5555
#
# Preduvjeti:
#   - Telefon spojen USB-om, USB debugging uključen
#   - adb instaliran na laptopu
#   - SSH pristup VPS-u

set -e

VPS="${1:-}"

if [[ -z "$VPS" ]]; then
  echo "Upotreba: $0 <user@vps-ip>"
  echo "Primjer:  $0 root@1.2.3.4"
  exit 1
fi

echo "[1/4] Provjera ADB uređaja..."
adb devices | grep -v "List of devices"

echo "[2/4] Prebacivanje telefona u TCP/IP mode na portu 5555..."
adb tcpip 5555

echo "[3/4] Dohvatanje WiFi IP adrese telefona..."
PHONE_IP=$(adb shell ip route 2>/dev/null | grep -oE 'src [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $2}' | head -1)

if [[ -z "$PHONE_IP" ]]; then
  echo "GREŠKA: Nije moguće dobiti IP telefona. Je li WiFi uključen?"
  exit 1
fi

echo "    Telefon IP: $PHONE_IP"

echo "[4/4] Otvaram SSH reverse tunel: ${VPS}:5555 → ${PHONE_IP}:5555"
echo "    Ostavi ovaj terminal otvoren. Ctrl+C za prekid."
echo ""
echo "    Na VPS-u pokreni:"
echo "      adb connect localhost:5555"
echo "      cd mogsh_app && flutter run"
echo ""

ssh -o ServerAliveInterval=30 \
    -o ExitOnForwardFailure=yes \
    -R 5555:"${PHONE_IP}":5555 \
    "$VPS" \
    -N
