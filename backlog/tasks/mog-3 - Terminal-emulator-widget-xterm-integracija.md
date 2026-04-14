---
id: MOG-3
title: Terminal emulator widget (xterm integracija)
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 19:53'
labels:
  - s1
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Flutter terminal widget koji renderuje ANSI output i prima keyboard input.
Ovo je srce app-a — mora biti fluidan i tačan.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Terminal prikazuje ANSI-colored Claude Code output bez lag-a
- [ ] #2 Font je JetBrains Mono, scroll fluidan pri 500+ linija outputa
- [ ] #3 Pinch-to-zoom radi u rasponu 11–18px
- [ ] #4 Selection mode (copy/paste terminal teksta) radi
- [ ] #5 xterm-256color kompatibilnost potvrđena
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Kreirati TerminalWidget kao Flutter WebView koji učitava xterm.js
2. HTML/JS bundle sa xterm.js + addons (FitAddon, WebLinksAddon, SearchAddon)
3. Dart↔JS bridge: pisanje u terminal, čitanje inputa
4. Pinch-to-zoom implementacija u JS sloju
5. JetBrains Mono font via assets
6. Integrisati TerminalWidget u main.dart kao proof of concept
<!-- SECTION:PLAN:END -->
