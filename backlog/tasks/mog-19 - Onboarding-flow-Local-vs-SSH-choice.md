---
id: MOG-19
title: Onboarding flow (Local vs SSH choice)
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:19'
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
- [ ] #1 Fresh install → onboarding → Local path → Claude Code autentificiran → `claude` radi u terminalu
- [ ] #2 Cijeli Local flow < 5 minuta za prosječnog korisnika
- [ ] #3 Skip radi na svakom koraku onboardinga
- [ ] #4 SSH path: dodaj server → konekcija → terminal u < 2 minute
- [ ] #5 Error recovery: ako provisioning faili → retry screen prikazan
<!-- AC:END -->
