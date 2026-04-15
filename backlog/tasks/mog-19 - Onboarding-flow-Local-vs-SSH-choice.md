---
id: MOG-19
title: Onboarding flow (Local vs SSH choice)
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-15 06:45'
labels:
  - s5
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
First-run iskustvo koje dovede korisnika do prvog "wow" momenta što brže moguće.
Cilj: < 5 minuta od install-a do `claude` koji radi.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Fresh install → onboarding → Local path → Claude Code autentificiran → `claude` radi u terminalu
- [x] #2 Cijeli Local flow < 5 minuta za prosječnog korisnika
- [x] #3 Skip radi na svakom koraku onboardinga
- [x] #4 SSH path: dodaj server → konekcija → terminal u < 2 minute
- [x] #5 Error recovery: ako provisioning faili → retry screen prikazan
<!-- AC:END -->
