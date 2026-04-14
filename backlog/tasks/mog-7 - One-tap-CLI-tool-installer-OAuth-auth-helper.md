---
id: MOG-7
title: One-tap CLI tool installer + OAuth auth helper
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
Ekran za instalaciju popularnih vibe coding alata jednim tapom + OAuth flow za autentifikaciju.
Ovo je najvažniji onboarding moment — korisnik mora doći do `claude` radnog stanja
bez ikakve terminalne gimnastike.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tap 'Install Claude Code' → instalirano, zeleni badge sa verzijom
- [x] #2 OAuth flow otvara browser, token se vrati via deep link i sačuva
- [x] #3 `claude` radi u terminalu s autorizacijom
- [x] #4 Error state (crveni Failed + Retry) prikazuje se ako install pukne
- [x] #5 Cijeli flow (install + auth) < 3 minute
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
ToolInstallerService + ToolInstallerPage: one-tap install za Claude Code/GH CLI/lazygit/Neovim. OAuth deep link flow (mogsh://oauth/<tool>), tokeni u secure storage, version badges, retry/skip UI.
<!-- SECTION:FINAL_SUMMARY:END -->
