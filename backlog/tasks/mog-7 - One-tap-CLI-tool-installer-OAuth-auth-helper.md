---
id: MOG-7
title: One-tap CLI tool installer + OAuth auth helper
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
Ekran za instalaciju popularnih vibe coding alata jednim tapom + OAuth flow za autentifikaciju.
Ovo je najvažniji onboarding moment — korisnik mora doći do `claude` radnog stanja
bez ikakve terminalne gimnastike.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Tap 'Install Claude Code' → instalirano, zeleni badge sa verzijom
- [ ] #2 OAuth flow otvara browser, token se vrati via deep link i sačuva
- [ ] #3 `claude` radi u terminalu s autorizacijom
- [ ] #4 Error state (crveni Failed + Retry) prikazuje se ako install pukne
- [ ] #5 Cijeli flow (install + auth) < 3 minute
<!-- AC:END -->
