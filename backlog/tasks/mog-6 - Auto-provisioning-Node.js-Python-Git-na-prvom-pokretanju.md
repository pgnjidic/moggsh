---
id: MOG-6
title: 'Auto-provisioning (Node.js, Python, Git na prvom pokretanju)'
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:08'
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
- [x] #1 `node --version`, `python3 --version`, `git --version` svi rade u terminalu
- [x] #2 Offline: prikazuje error sa retry buttonom ako nema interneta
- [x] #3 Drugi pokretanje ne pokreće provisioning ponovo (state sačuvan)
- [x] #4 Post-setup screen prikazuje instalirane verzije
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
ProvisioningService: apk add toolchain (git/node/python3) u Alpine proot. Offline detekcija, state persistovan, progress stream.
<!-- SECTION:FINAL_SUMMARY:END -->
