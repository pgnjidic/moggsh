---
id: MOG-10
title: SSH konekcija (dartssh2 integracija)
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
