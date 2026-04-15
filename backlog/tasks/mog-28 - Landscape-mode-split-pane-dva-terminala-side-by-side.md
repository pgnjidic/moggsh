---
id: MOG-28
title: Landscape mode + split pane (dva terminala side-by-side)
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:19'
labels:
  - v1.2
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Landscape je odličan za čitanje dugačkog AI outputa — full width terminal.
Split pane je killer feature za power users: agent u lijevom, output/logs u desnom.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Rotate u landscape → terminal zauzima punu širinu ekrana
- [ ] #2 Split pane: dva terminala rade nezavisno sa nezavisnim scrollback bufferima
- [ ] #3 Divider je resizeable drag-om (30%–70%)
- [ ] #4 Ctrl+C u jednom pane ne utječe na drugi
<!-- AC:END -->
