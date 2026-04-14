---
id: MOG-12
title: SSH key management + biometric unlock
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:13'
labels:
  - s3
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Sigurno upravljanje SSH ključevima na Androidu. Ključevi se nikad ne čuvaju plain-text.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Generiši Ed25519 key, kopiraj public key, poveži se na server s tim keyem
- [ ] #2 Biometrija zahtjevana za export private keya
- [ ] #3 Import iz OpenSSH format fajla radi
- [ ] #4 Encrypted key traži passphrase, passphrase se čuva samo u session memoriji
<!-- AC:END -->
