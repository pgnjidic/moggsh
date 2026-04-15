---
id: MOG-31
title: Multi-agent instance switching
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-15 06:45'
labels:
  - s4
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Brzo skakanje između više Claude/agent instanci koje paralelno rade.
Svaka instanca je tab, ali trebamo poseban UX sloj koji razumije da su to
agenti, ne samo terminali — i koji može automatski prebacivati fokus.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 3 aktivna Claude Code taba: auto-switch skače na tab koji čeka `(y/n)`
- [x] #2 Nakon odgovora (Return mode): app se vrati na prethodni tab
- [x] #3 Pinned tab: nikad ne gubi fokus zbog auto-switch
- [x] #4 Agent status overlay (24px) prikazuje tačne statuse sva 3 agenta u realnom vremenu
- [x] #5 Settings: auto-switch toggle i after-response behavior konfigurabilan
<!-- AC:END -->
