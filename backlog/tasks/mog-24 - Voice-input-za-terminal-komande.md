---
id: MOG-24
title: Voice input za terminal komande
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:19'
labels:
  - v1.1
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Android Speech-to-Text integracija za hands-free terminal input.
Koristan za duže promptove — izgovoриш umjesto tipkaš.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Hold voice button, izgovori 'git status' → komanda se pojavi u input field
- [ ] #2 Release → šalje se u terminal
- [ ] #3 Radi offline sa downloaded Google STT modelom
- [ ] #4 'slash plan' izgovoreno → `/plan` u inputu
<!-- AC:END -->
