---
id: MOG-6
title: 'Auto-provisioning (Node.js, Python, Git na prvom pokretanju)'
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:05'
labels:
  - s2
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Pri prvom pokretanju Local moda, automatski instalirati dev toolchain.
Korisnik ne smije ručno ništa instalirati — to je naš core promise.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `node --version`, `python3 --version`, `git --version` svi rade u terminalu
- [ ] #2 Offline: prikazuje error sa retry buttonom ako nema interneta
- [ ] #3 Drugi pokretanje ne pokreće provisioning ponovo (state sačuvan)
- [ ] #4 Post-setup screen prikazuje instalirane verzije
<!-- AC:END -->
