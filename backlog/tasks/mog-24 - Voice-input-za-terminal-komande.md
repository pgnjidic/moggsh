---
id: MOG-24
title: Voice input za terminal komande
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-15 06:45'
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
- [x] #1 Hold voice button, izgovori 'git status' → komanda se pojavi u input field
- [x] #2 Release → šalje se u terminal
- [x] #3 Radi offline sa downloaded Google STT modelom
- [x] #4 'slash plan' izgovoreno → `/plan` u inputu
<!-- AC:END -->
