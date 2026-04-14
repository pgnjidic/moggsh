---
id: MOG-13
title: tmux session detection + reattach dialog
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:16'
labels:
  - s3
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Automatski detektuj tmux sesije odmah nakon SSH konekcije i ponudi reattach.
Nikad više ručni `tmux attach`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 SSH na server sa 2 tmux sesije → bottom sheet prikazuje obje → tap → reattach
- [x] #2 Terminal prikazuje tmux sučelje nakon reattach-a
- [x] #3 Server bez tmux-a → direktan shell bez dijaloga
- [x] #4 Per-server startup script override zaobilazi session picker
<!-- AC:END -->
