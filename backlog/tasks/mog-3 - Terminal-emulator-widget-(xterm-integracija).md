---
id: MOG-3
title: Terminal emulator widget (xterm integracija)
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s1
dependencies: []
priority: medium
---

## Opis

Flutter terminal widget koji renderuje ANSI output i prima keyboard input.
Ovo je srce app-a — mora biti fluidan i tačan.

## Zadaci

- Evaluirati i odabrati: `xterm` (flutter_pty) vs custom native channel
- Terminal widget koji podržava:
  - ANSI escape codes (boje, bold, italic, cursor movement)
  - `xterm-256color` (kritično za Claude Code / Aider output)
  - Scrollback buffer (min 10.000 linija)
  - UTF-8 + emoji
  - Resize/reflow na promjenu veličine ekrana
- JetBrains Mono font bundlan u `assets/fonts/`
- Pinch-to-zoom font size (raspon 11–18px)
- Selection mode za copy/paste terminal teksta
- Performans test: 500 linija AI outputa → scroll mora biti 60fps na
  mid-range Android (Snapdragon 665, 4GB RAM)

## Acceptance criteria

Terminal prikazuje ANSI-colored Claude Code output bez lag-a, font je JetBrains Mono,
scroll fluidan pri 500+ linija, pinch-to-zoom radi.
