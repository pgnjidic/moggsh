---
id: MOG-6
title: Auto-provisioning (Node.js, Python, Git na prvom pokretanju)
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s2
dependencies: []
priority: medium
---

## Opis

Pri prvom pokretanju Local moda, automatski instalirati dev toolchain.
Korisnik ne smije ručno ništa instalirati — to je naš core promise.

## Zadaci

- Provisioning screen: "Setting up your environment..." sa animated progress barom
- Async instali u pozadini sa progress callbacks:
  1. Node.js LTS (prebuilt ARM64 binary ili nvm)
  2. Python 3 + pip
  3. Git
  4. curl
- Verzije: uvijek latest stable (download sa interneta, ne bundlano)
- Offline fallback: "Connect to internet for setup" + Retry button
- Provisioning state u Hive — ne ponavljati ako već done
- Post-setup screen: "Environment ready!" + lista instaliranog sa verzijama
- Re-provision opcija u Settings ako nešto pukne

## Blokiran na

- 0005 (terminal mora raditi)

## Acceptance criteria

Fresh install → auto-provisioning → `node --version`, `python3 --version`,
`git --version` svi rade u terminalu. Offline prikazuje error s retry.
Drugi pokretanje ne pokreće provisioning ponovo.
