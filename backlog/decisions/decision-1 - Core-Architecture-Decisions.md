---
id: decision-1
title: Core Architecture Decisions
date: '2026-04-14'
status: accepted
---
## Context

mogsh je Android terminal emulator app namijenjen power userima — SSH konekcije na servere i lokalni Linux environment
na samom uređaju. Potrebno je donijeti temeljne arhitekturalne odluke prije početka razvoja.

## Decision

### 1. Framework: Flutter
- Cross-platform (Android primary, iOS moguć u budućnosti)
- Jedna codebase, dobar performance
- Bogat ecosystem za terminal UI (xterm.js via WebView ili native rješenje)

### 2. Package name: `app.mogsh.terminal`
- Org: `app.mogsh`
- Projekt: `terminal`
- Play Store bundle ID: `app.mogsh.terminal`

### 3. Task prefix: `MOG`
- Svi backlog taskovi koriste prefiks MOG (MOG-1, MOG-2, ...)

### 4. Local Linux environment: proot-distro
- Ne zahtijeva root pristup
- Omogućava pokretanje Debian/Ubuntu na Android uređaju
- Koristi se za lokalni terminal (ne-SSH workflow)

### 5. SSH library: dartssh2
- Pure-Dart implementacija SSH klijenta
- Nema native dependencija, lako deployable

### 6. Terminal emulator: xterm.js via Flutter WebView
- Industrijski standard terminal emulator
- Odlična ANSI/VT100 podrška
- Integriše se kao WebView widget u Flutter

### 7. Design aesthetic: Cyberpunk
- Tamna tema, neon akcenti (zelena/cyan/magenta)
- Monospace fontovi (JetBrains Mono / Fira Code)
- Blur/glow efekti gdje performanse dozvoljavaju

### 8. Storage: flutter_secure_storage + SharedPreferences
- SSH ključevi i credentialsi u secure storage (biometric unlock)
- App settings u SharedPreferences

## Consequences

- Flutter toolchain je obavezna dev dependency
- proot-distro ograničava lokalni environment na ARM Android uređaje
- xterm.js WebView može imati performance overhead na starijim uređajima
- dartssh2 je community-maintained, treba pratiti maintenance status
