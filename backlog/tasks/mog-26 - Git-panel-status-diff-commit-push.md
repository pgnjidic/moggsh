---
id: MOG-26
title: 'Git panel (status, diff, commit, push)'
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-15 06:45'
labels:
  - v1.2
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Vizualni git panel unutar app-a — git workflow bez terminala.
Radi i za local mode i za SSH mode (isti UI, isti shell-out).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Git repo, promijeni fajl, otvori git panel → promjena vidljiva sa M ikonom
- [x] #2 Stage fajl, unesi commit message, commit, push — bez direktnog terminala
- [x] #3 Diff pregled radi za .dart i .md fajlove
- [x] #4 Branch info (trenutna branch + remote tracking) tačan
<!-- AC:END -->
