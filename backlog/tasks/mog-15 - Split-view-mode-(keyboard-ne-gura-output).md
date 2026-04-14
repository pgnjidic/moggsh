---
id: MOG-15
title: Split view mode (keyboard ne gura output)
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s4
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Najvažniji UX differentiator. Keyboard NE pomjera terminal output.
Korisnik čita AI output dok tipka komandu.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Claude Code ispisuje 300 linija, korisnik skrola gore, keyboard se otvori — terminal output iznad ostaje vidljiv
- [ ] #2 Keyboard NE pomjera terminal content
- [ ] #3 FAB (Scroll to prompt) pojavi se kad korisnik nije na dnu
- [ ] #4 Tap FAB → animirani scroll do zadnjeg `❯` prompta
- [ ] #5 Expanded input mode (4 linije) dostupan via tap na input field
<!-- AC:END -->


## Problem

Na standardnom Androidu keyboard push-a cijeli sadržaj gore — 50% ekrana nestaje
dok tipkaš. Korisnik gubi kontekst Claude Code outputa dok šalje komandu.

## Layout Mode 1 — Compact Input (default)

- Terminal output: gornji dio ekrana (90% kad keyboard nije aktivan)
- Shortcut bar: fiksiran, odmah iznad tastature
- Single-line input field: ispod shortcut bara, lijevo od Send buttona
- **Keyboard ponašanje**: keyboard se pojavi ispod inputa — terminal NE reflow-a
- Terminal ostaje vidljiv iznad input-a
- Implementacija: `android:windowSoftInputMode="adjustResize"` u manifestu,
  ali terminal area ima `fixed height = screenHeight - statusBar - tabBar - shortcutBar - inputBar`

## Layout Mode 2 — Expanded Input

- Tap na input field → expand na 4-line multiline field
- Terminal shrink ali ostaje vidljiv gore
- "Collapse" gumb za povratak na compact

## "Scroll to last prompt" FAB

- Pojavi se kad korisnik nije na dnu scroll buffera
- Dizajn: mali FAB desno, `⬇` ikona sa neon glow
- Tap → animirani scroll na posljednji `❯` prompt u bufferu
- Nestaje automatski kad je korisnik na dnu
