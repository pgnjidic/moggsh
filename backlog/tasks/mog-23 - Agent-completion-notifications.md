---
id: MOG-23
title: Agent completion notifications
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:19'
labels:
  - v1.1
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Notifikacija kada AI agent završi task — korisnik može odložiti telefon i dobiti ping.
Nema potrebe stare u ekran dok Claude Code radi.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Pokreni agent task, minimizuj app → notifikacija stigne < 3s od completion
- [ ] #2 Tap notifikacije → otvori terminal tab na zadnji output
- [ ] #3 Quiet hours: nema notifikacije u postavljenom periodu
- [ ] #4 Toggle per-tab radi (samo označeni tabovi šalju notifikacije)
<!-- AC:END -->
