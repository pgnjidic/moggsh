---
id: MOG-28
title: Landscape mode + split pane (dva terminala side-by-side)
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - v1.2
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Landscape je odličan za čitanje dugačkog AI outputa — full width terminal.
Split pane je killer feature za power users: agent u lijevom, output/logs u desnom.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Rotate u landscape → terminal zauzima punu širinu ekrana
- [ ] #2 Split pane: dva terminala rade nezavisno sa nezavisnim scrollback bufferima
- [ ] #3 Divider je resizeable drag-om (30%–70%)
- [ ] #4 Ctrl+C u jednom pane ne utječe na drugi
<!-- AC:END -->


## Layout promjene u landscape

- Tab bar: vertical left sidebar (uži, samo ikone + status dot)
- Terminal area: puna širina (minus sidebar)
- Shortcut bar: hidden by default u landscape (toggle u Settings)
- Keyboard: terminal reflow-a u landscape (više info na ekranu)

## Split pane mode (landscape)

- Dva terminala side-by-side, 50/50 split ili resizeable (drag divider)
- Svaki pane = nezavisni tab, nezavisni scrollback buffer
- Use case: Claude Code lijevo, `tail -f` ili `git log` desno

**Aktivacija:**
- Long press na tab → "Open in split view"
- Drag tab u drugu polovicu ekrana
- Swipe divider za resize (min 30% / max 70%)

## Landscape geste

| Gesta | Akcija |
|-------|--------|
| Two-finger swipe down | Sakrij keyboard |
| Two-finger swipe up | Prikaži keyboard |
| Tap sidebar tab | Switch tab (bez swipe-a) |

## Font size u landscape

- Auto: +1px u landscape (više piksela dostupno po liniji)
- Override u Settings
