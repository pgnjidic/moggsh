---
id: MOG-9
title: Smart shortcut bar + swipe geste
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
Prilagodljivi redovi tipki iznad system tastature + swipe geste na terminal area.
Nadomjestak za sve što mobilni keyboard ne može.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ctrl+C radi via Ctrl modifier + C button
- [x] #2 Swipe gore na terminal area povlači prethodnu komandu iz historije
- [x] #3 Custom snippet šalje se jednim tapom
- [x] #4 Snippet manager: add/delete/reorder radi
- [x] #5 Haptic feedback na svaki tap buttona
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
ShortcutBar: built-in keys + custom snippets sa persistent storage + ReorderableListView manager. Swipe up → history arrow. HapticFeedback na sve taps.
<!-- SECTION:FINAL_SUMMARY:END -->
