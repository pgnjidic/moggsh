---
id: MOG-1
title: Project kickoff & open decisions
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 18:44'
labels:
  - s1
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Razriješiti sve otvorene odluke prije nego što dev počne. Svaka nerješena odluka
blokira ili usporava sprint 1.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Sve arhitekturalne odluke dokumentovane (ADR fajl u backlog/decisions/)
- [x] #2 Flutter projekt inicijaliziran na GitHubu
- [ ] #3 mogsh.app domen registrovan
- [ ] #4 Play Store developer account aktivan
- [x] #5 Task prefix MOG potvrđen, package name app.mogsh.terminal potvrđen
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Monorepo struktura uspostavljena (mogsh_app/, mogsh_web/, mogsh_api/ ready).

Uradjeno:
- Flutter 3.41.6 scaffold u mogsh_app/ (package: app.mogsh.terminal)
- decision-1 ADR dokumentovan (framework, storage, SSH lib, design aesthetic)
- Task prefix MOG potvrđen, package name app.mogsh.terminal potvrđen
- Pushano na pgnjidic/mogsh

Otvoreno (van CLI kontrole):
- AC3: mogsh.app domen — pending
- AC4: Play Store developer account — pending
<!-- SECTION:FINAL_SUMMARY:END -->
