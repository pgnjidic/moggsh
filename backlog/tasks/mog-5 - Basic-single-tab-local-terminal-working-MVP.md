---
id: MOG-5
title: Basic single-tab local terminal (working MVP)
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:03'
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
- [x] #1 Korisnik može pokrenuti `bash`, ukucati `ls -la`, dobiti output
- [x] #2 Ctrl+C via button prekida aktivni proces
- [x] #3 App suspend/resume čuva terminal sesiju aktivnom (foreground service)
- [x] #4 Crash recovery: ako PTY umre, reconnect screen se prikazuje
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Android Foreground Service za PTY (drzi sesiju zivu pri suspend/resume)
2. Ctrl+C button u UI (salje ETX/0x03 na PTY)
3. Crash recovery: PTY onDone → reconnect screen
4. Refaktorisati TerminalPage da koristi foreground service
<!-- SECTION:PLAN:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Working MVP terminal spojen — xterm widget + proot shell + lifecycle management.

Isporučeno:
- Ctrl+C dugme u UI (salje ETX na PTY, prekida aktivni proces)
- Android ForegroundService drzi PTY sesiju zivu pri app suspend/resume
- MethodChannel bridge Flutter → Android za start/stop foreground service
- onCrash stream na PtermService → _CrashOverlay sa Reconnect dugmetom
- restart() metoda za obnavljanje sesije bez reinstalla
<!-- SECTION:FINAL_SUMMARY:END -->
