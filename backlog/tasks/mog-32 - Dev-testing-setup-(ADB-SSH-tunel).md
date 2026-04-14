---
id: MOG-32
title: Dev/testing setup (ADB SSH tunel)
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - infra
dependencies: []
priority: medium
---

## Kontekst

VPS je Hetzner, nema KVM (`/proc/cpuinfo` vratio 0) — Android emulator ne radi.
Jedini funkcionalni dev workflow je ADB over SSH tunnel sa fizičkim telefonom.

## Setup (jednom)

```bash
# 1. Telefon: Developer options → USB debugging ON
# 2. Spoji telefon USB na laptop
# 3. Na laptopu:
adb tcpip 5555
adb devices   # potvrdi da vidi telefon

# 4. SSH tunel sa laptopa na VPS:
ssh -R 5555:localhost:5555 user@vps

# 5. Na VPS-u (drugi terminal):
adb connect localhost:5555
adb devices   # treba vidjeti telefon

# 6. flutter run
```

## Dnevni workflow

1. Spoji telefon USB na laptop
2. `adb tcpip 5555`
3. `ssh -R 5555:localhost:5555 user@vps` (ili dodaj u SSH config kao alias)
4. Na VPS-u: `adb connect localhost:5555 && flutter run`

Hot reload (`r`) i hot restart (`R`) rade normalno kroz tunel.

## APK sideload (alternativa za brze testove bez tunnela)

```bash
flutter build apk --debug
python3 -m http.server 8080   # servira APK na http://vps-ip:8080
# na telefonu: otvori URL, instaliraj
```

## Acceptance criteria

`flutter run` na VPS-u deploya direktno na fizički telefon. Hot reload radi.
