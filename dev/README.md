# Dev/Testing Setup — ADB SSH Tunel

VPS (Hetzner) nema KVM podrške pa Android emulator ne radi.
Workflow: fizički telefon spojjen USB-om na laptop, VPS deployuje via SSH reverse tunnel.

## Preduvjeti

### Laptop (Pop!_OS)
```bash
sudo apt install adb
```

### Telefon
1. Postavke → O telefonu → tap 7x na Build number (otključaj Developer Options)
2. Postavke → Developer Options → USB Debugging: ON
3. WiFi mora biti uključen (potreban za IP)

### VPS
```bash
# Instaliraj ADB i Flutter tooling
apt install adb
# Flutter je instaliran via snap (već urađeno)
```

---

## Workflow: flutter run via ADB tunel

### Korak 1 — Laptop: otvori tunel

```bash
cd mogsh/dev
chmod +x adb-tunnel.sh
./adb-tunnel.sh root@<vps-ip>
```

Skripta:
- Prebacuje telefon u `tcpip` mode
- Dohvata WiFi IP telefona
- Otvara SSH reverse tunel: `VPS:5555 → telefon:5555`

Ostavi ovaj terminal otvoren.

### Korak 2 — VPS: poveži ADB i pokreni app

```bash
adb connect localhost:5555
adb devices                    # treba pokazati telefon
cd moggsh_app
flutter run
```

### Hot reload

Dok `flutter run` radi:
- `r` — hot reload
- `R` — hot restart
- `q` — quit

---

## Fallback: APK sideload

Ako tunel nije opcija (nestabilna veza, firewall), buildaj APK na VPS-u i instaliraj ručno.

### Na VPS-u
```bash
cd moggsh_app
flutter build apk --debug
# APK je u: build/app/outputs/flutter-apk/app-debug.apk
```

### Prebaci na laptop
```bash
scp root@<vps-ip>:/root/mogsh/moggsh_app/build/app/outputs/flutter-apk/app-debug.apk .
```

### Instaliraj na telefon (laptop)
```bash
adb install app-debug.apk
```

---

## Troubleshooting

| Problem | Rješenje |
|---|---|
| `adb devices` prazno | Provjeri USB kabel + prihvati prompt na telefonu |
| `unauthorized` | Prihvati "Allow USB debugging" na telefonu |
| `cannot connect to localhost:5555` | Provjeri je li tunel skripta pokrenuta i aktivan |
| `flutter run` ne vidi uređaj | `adb kill-server && adb start-server` na VPS-u |
| Tunel se prekida | `ssh` flag `-o ServerAliveInterval=30` bi trebao držati vezu |
