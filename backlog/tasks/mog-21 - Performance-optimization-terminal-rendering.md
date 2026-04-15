---
id: MOG-21
title: Performance optimization (terminal rendering)
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:19'
labels:
  - s5
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Terminal mora biti fluidan. Ovo je make-or-break za app — jedino gdje možemo
izgubiti 5-star review odmah.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Scroll kroz 500 linija AI outputa = 60fps na Snapdragon 665 / 4GB RAM
- [ ] #2 App startup do usable terminal < 2 sekunde
- [ ] #3 APK download size < 30MB
- [ ] #4 1000 linija scrollback bez lag-a ili OOM crash-a
<!-- AC:END -->
