---
id: MOG-10
title: SSH konekcija (dartssh2 integracija)
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s3
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Profesionalni SSH klijent koji ne crasha, ne gubi konekciju bez razloga,
i radi transparentno u pozadini.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Konekcija na VPS, `htop` radi sa ANSI colors
- [ ] #2 `Ctrl+C` prekida remote procese
- [ ] #3 Simuliran network drop → auto-reconnect bez user akcije
- [ ] #4 Known host fingerprint warning prikazan pri promjeni
- [ ] #5 Password i SSH key auth oba rade
<!-- AC:END -->


## Zadaci

- `dartssh2` package za SSH protokol
- Auth metodi: password, SSH key (RSA, Ed25519, ECDSA)
- Konekcija flow: connect → auth → shell request → PTY request
  (`xterm-256color`, trenutne dimenzije ekrana)
- Keepalive: `ServerAliveInterval 30s`, `ServerAliveCountMax 3`
- Disconnect handling: razlikuj čisti disconnect od network drop
- Auto-reconnect: exponential backoff (1s → 2s → 4s → 8s → 30s → stop)
  sa status indicator u tab bar-u
- Known hosts verifikacija: sačuvaj fingerprint pri prvom connectu,
  upozori na mismatch (TOFU model)
- Connection banner (MOTD) prikaži u terminalu
- Terminal resize: SSH channel resize request na keyboard show/hide
