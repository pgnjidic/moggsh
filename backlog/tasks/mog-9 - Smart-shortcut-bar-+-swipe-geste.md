---
id: MOG-9
title: Smart shortcut bar + swipe geste
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s2
dependencies: []
priority: medium
---

## Opis

Prilagodljivi redovi tipki iznad system tastature + swipe geste na terminal area.
Nadomjestak za sve što mobilni keyboard ne može.

## Layout (3 reda po design sistemu)

```
Row 1 (function):  [ESC] [F1] [F2] [F3] [F4] [F5] [F6]
Row 2 (modifiers): [Tab] [Ctrl] [Alt] [C] [D] [Z] [↑] [PgUp]
Row 3 (nav+voice): [←] [↑] [↓] [→] [🎤 VOICE] [/] [~] [|]
```

- ESC: neon-ghost bg, highlighted
- Ctrl: amber bg, highlighted (modifier lock kad tap-and-hold)
- Voice: 48×48px kružni, radial gradient, neon glow

## Svaki key button

- Haptic feedback: `HapticFeedback.lightImpact` na tap
- Visual flash: opacity 0.08→0.15, 80ms
- Ctrl modifier lock: ostaje aktivan dok ne tapneš sljedeći taster

## Snippet sistem

- Custom snippet: label (max 8 char) + command string
- Snippet tap → šalje u terminal (sa Enter ili bez — user bira)
- Default snippeti: `/plan`, `git status`, `exit`, `clear`
- Snippet Manager screen: add/edit/delete/drag-to-reorder
- Shortcut bar konfiguracija: drag snippete u bar, max 12 po redu

## Swipe geste na terminal area

| Gesta | Akcija |
|-------|--------|
| Swipe desno | ← arrow |
| Swipe lijevo | → arrow |
| Swipe gore | ↑ (history previous) |
| Swipe dolje | ↓ (history next) |

Sensitivity podesiva u Settings (Low / Medium / High).

## Acceptance criteria

Ctrl+C radi via button. Swipe gore povlači prethodnu komandu.
Custom snippet šalje se jednim tapom. Snippet manager: add/delete/reorder.
