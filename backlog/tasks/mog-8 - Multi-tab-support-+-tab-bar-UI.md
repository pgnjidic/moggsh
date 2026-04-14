---
id: MOG-8
title: Multi-tab support + tab bar UI
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s2
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tab sistem koji miješa lokalne i remote sesije. Swipe između projekata.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 3 simultana taba (2 local, 1 SSH) rade nezavisno
- [ ] #2 Swipe left/right između tabova radi
- [ ] #3 Svaki tab ima nezavisan scrollback buffer
- [ ] #4 Status dot tačno prikazuje stanje sesije (active/idle/offline)
- [ ] #5 Long-press rename taba radi
<!-- AC:END -->


## Data model

```dart
class TabSession {
  String id;          // UUID
  String name;        // projekt ime
  TabType type;       // local | ssh
  TabStatus status;   // active | idle | offline
  // process ref ili sshClient ref
  ScrollbackBuffer buffer;
}
```

Max tabova: 8 (Android memory constraint).

## Tab Bar UI (po design sistemu)

- Pozicija: ispod status bara, iznad terminal area
- Horizontalno scrollable (ako > 4 tabova)
- Svaki tab: mod ikona (📱 / 🖥) + projekt ime + status dot sa glow
- Active tab: `neon-ghost` background + `neon-border`
- Inactive tab: dim
- Long-press → info sheet (rename, close, session info)
- "+" button na kraju za novi tab
- Swipe left/right na terminal area za switch između tabova

## Implementacija

- `IndexedStack` ili `PageView` za tab content (ne rebuild na switch)
- Nezavisni ScrollbackBuffer per tab
- Novi tab: bottom sheet "New Local Terminal" vs "New SSH Connection"

## Blokiran na

- 0005 (terminal MVP mora raditi)
