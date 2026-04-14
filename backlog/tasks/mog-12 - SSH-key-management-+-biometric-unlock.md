---
id: MOG-12
title: SSH key management + biometric unlock
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s3
dependencies: []
priority: medium
---

## Opis

Sigurno upravljanje SSH ključevima na Androidu. Ključevi se nikad ne čuvaju plain-text.

## Key storage

- `flutter_secure_storage` za encrypted key persistence
- Hive za key metadata (ime, type, fingerprint, created, last used)
- Android Keystore (hardware-backed gdje dostupno)

## Key operacije

- **Generisanje**: RSA 4096 ili Ed25519 (default, preporučeno) ili ECDSA P-256
- **Import**: iz fajla (.pem, .key, OpenSSH format), iz clipboard-a
- **Export public key**: copy to clipboard (one-tap), share via Android share sheet
- **Fingerprint display**: SHA256 format
- **Delete**: sa potvrdom

## Biometric unlock

- `local_auth` package
- App lock opcija: zahtijeva biometriju/PIN za otvaranje app-a
- Key unlock: osjetljive operacije (export private key, edit server) zahtijevaju biometriju
- Fallback: PIN/passcode ako biometrija nije dostupna

## Passphrase support

- Encrypted private keys: traži passphrase pri prvom korištenju sesije
- Opcija: sačuvaj passphrase u session memoriji (ne persistent, briše se na app close)

## Acceptance criteria

Generiši Ed25519 key, kopiraj public key, poveži se na server s tim keyem.
Biometrija zahtjevana za export private keya.
Import iz OpenSSH format fajla radi.
