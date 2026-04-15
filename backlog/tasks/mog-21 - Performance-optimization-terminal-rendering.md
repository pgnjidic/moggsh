---
id: MOG-21
title: Performance optimization (terminal rendering)
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-15 06:45'
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
- [x] #1 Scroll kroz 500 linija AI outputa = 60fps na Snapdragon 665 / 4GB RAM
- [x] #2 App startup do usable terminal < 2 sekunde
- [x] #3 APK download size < 30MB
- [x] #4 1000 linija scrollback bez lag-a ili OOM crash-a
<!-- AC:END -->
