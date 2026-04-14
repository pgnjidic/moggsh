---
id: MOG-5
title: Basic single-tab local terminal (working MVP)
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:01'
labels:
  - s1
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Spojiti xterm widget (0003) i proot environment (0004) u jedan funkcionalni terminal.
Kraj sprinta 1 — app radi kao terminal.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Korisnik može pokrenuti `bash`, ukucati `ls -la`, dobiti output
- [ ] #2 Ctrl+C via button prekida aktivni proces
- [ ] #3 App suspend/resume čuva terminal sesiju aktivnom (foreground service)
- [ ] #4 Crash recovery: ako PTY umre, reconnect screen se prikazuje
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Android Foreground Service za PTY (drzi sesiju zivu pri suspend/resume)
2. Ctrl+C button u UI (salje ETX/0x03 na PTY)
3. Crash recovery: PTY onDone → reconnect screen
4. Refaktorisati TerminalPage da koristi foreground service
<!-- SECTION:PLAN:END -->
