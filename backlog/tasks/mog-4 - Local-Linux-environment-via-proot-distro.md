---
id: MOG-4
title: Local Linux environment via proot-distro
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:01'
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
- [x] #1 `bash` shell radi unutar app-a, `ls`, `echo $HOME`, `pwd` funkcionišu
- [x] #2 Filesystem persists između restarta app-a
- [x] #3 Progress screen prikazan tokom prvog extractiona
- [x] #4 Alpine Linux ARM64 environment funkcionalan na fizičkom Android uređaju
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

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
proot + Alpine Linux environment implementiran.

Isporučeno:
- PtermService: download proot binary (Termux build) + Alpine 3.20 minirootfs (ARM64) pri prvom pokretanju
- PTY session via flutter_pty — bash/sh unutar Alpine chroot-a
- Filesystem persistentan u app storage (getApplicationSupportDirectory)
- SetupScreen: progress bar sa label-ima tokom download/extract faze, retry na gresku
- TerminalPage: auto-detektuje first-run, wires PTY output → TerminalWidget
- AndroidManifest: INTERNET permission dodan
<!-- SECTION:FINAL_SUMMARY:END -->
