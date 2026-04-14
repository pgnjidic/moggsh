---
id: MOG-8
title: Multi-tab support + tab bar UI
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:11'
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
- [x] #1 3 simultana taba (2 local, 1 SSH) rade nezavisno
- [x] #2 Swipe left/right između tabova radi
- [x] #3 Svaki tab ima nezavisan scrollback buffer
- [x] #4 Status dot tačno prikazuje stanje sesije (active/idle/offline)
- [x] #5 Long-press rename taba radi
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
TerminalTab + TabManager + MogshTabBar + MultiTabScreen. PageView swipe, per-tab scrollback, session state dot, long-press rename, max 5 tabova.
<!-- SECTION:FINAL_SUMMARY:END -->
