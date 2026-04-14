---
id: MOG-5
title: Basic single-tab local terminal (working MVP)
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
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


## Zadaci

- PTY bridge: xterm widget piše user input u master PTY, čita output iz master PTY
- Resize events: kad se keyboard pojavi/nestane → `SIGWINCH` shell procesu
- Keyboard input: svi Unicode karakteri + specijalni tasteri (Enter, Backspace, Ctrl+X)
- `Ctrl+C` via custom button (mobilni keyboard ne šalje Ctrl)
- App lifecycle:
  - Pause/resume čuva terminal sesiju (process nastavlja raditi u pozadini)
  - Foreground service + notifikacija dok terminal radi u pozadini
- Crash recovery: ako PTY process umre → "Reconnect" screen

## Blokiran na

- 0003 (xterm widget mora biti gotov)
- 0004 (proot environment mora biti gotov)
