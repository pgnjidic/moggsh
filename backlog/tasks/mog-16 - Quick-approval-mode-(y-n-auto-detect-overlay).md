---
id: MOG-16
title: Quick approval mode (y/n auto-detect overlay)
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
Kada AI agent traži potvrdu, prikaži veliki Y/N overlay umjesto tipkanja.
Jedan tap umjesto tipkanja `y` + Enter.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Claude Code ispiše '(y/n)' → approval banner se pojavi u < 500ms
- [ ] #2 Tap Y → odgovor poslan, agent nastavlja
- [ ] #3 Tap N → negativan odgovor poslan
- [ ] #4 False positive → dismiss bez slanja radi
- [ ] #5 Toggle za isključivanje feature-a u Settings radi
<!-- AC:END -->


## Pattern detection (regex na incoming output)

```
(y/n)  |  (Y/n)  |  (N/y)
proceed?  |  continue?  |  confirm?
[yes/no]
```

- Debounce: 300ms od posljednjeg output bajta (čekaj da agent završi pisati)
- Korisnik može dodati custom patterns u Settings

## Overlay UI (po design sistemu — amber tema)

In-terminal banner, NE full-screen overlay (terminal mora ostati vidljiv):

```
┌─────────────────────────────────────────┐
│ ⚡ Agent needs approval                  │
│ "Do you want to proceed? (y/n)"         │
│  [      Y      ]  [   N   ]  [ Edit ]   │
└─────────────────────────────────────────┘
```

- Amber background (`#ffaa0018`) + amber border
- Y button: zeleni, velik, šalje `y\n`
- N button: crveni, šalje `n\n`
- Edit button: sivi, fokusira input field (custom odgovor)
- Auto-dismiss nakon slanja
- Haptic: `HapticFeedback.mediumImpact` na Y ili N

## Edge cases

- Nested agents koji pitaju više puta brzo — queue approvals
- False positives — korisnik može dismiss banera bez odgovaranja
- Accessibility: screen reader najavi approval potrebu

## Settings

- Toggle On/Off za cijeli feature
- Custom pattern lista
