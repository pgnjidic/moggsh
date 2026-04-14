---
id: MOG-4
title: Local Linux environment via proot-distro
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 19:57'
labels:
  - s1
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Embeddati Linux environment u Android app bez root-a, koristeći proot.
Ovo je osnova Local moda — bez ovoga nema "instaliraj i kodiraj".
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `bash` shell radi unutar app-a, `ls`, `echo $HOME`, `pwd` funkcionišu
- [ ] #2 Filesystem persists između restarta app-a
- [ ] #3 Progress screen prikazan tokom prvog extractiona
- [ ] #4 Alpine Linux ARM64 environment funkcionalan na fizičkom Android uređaju
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Kreirati PtermService — Dart wrapper oko Android PTY (process_run ili native MethodChannel)
2. Download + extract Alpine ARM64 rootfs u app files directory pri prvom pokretanju
3. Wrapper koji pokrece proot sa Alpine rootfs-om
4. Povezati PtermService sa TerminalWidget (stdin/stdout bridge)
5. Persistentni filesystem — rootfs ostaje u app storage
6. SetupScreen — progress bar tokom prvog extractiona
<!-- SECTION:PLAN:END -->
