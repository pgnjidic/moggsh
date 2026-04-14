---
id: MOG-4
title: Local Linux environment via proot-distro
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s1
dependencies: []
priority: medium
---

## Opis

Embeddati Linux environment u Android app bez root-a, koristeći proot.
Ovo je osnova Local moda — bez ovoga nema "instaliraj i kodiraj".

## Zadaci

- proot-distro approach: bundlati Alpine Linux ARM64 base image u app assets
- Flutter `MethodChannel` bridge (Dart ↔ native Android/Kotlin)
- PTY creation: Kotlin kreira pseudoterminal, Flutter čita/piše
- Environment setup:
  - `PATH`, `HOME`, `TERM=xterm-256color`, `LANG=en_US.UTF-8`
  - Working directory: `/data/data/app.mogsh.terminal/files/home`
  - Symlink: `~/projects` → Android shared storage (uz permission)
- Shell: `bash` (Alpine default je `ash` — trebamo bash za compatibility)
- First-run: proot filesystem extraction iz app assets (~50MB compressed)
  sa progress screen tokom extractiona
- Filesystem persists između restarta app-a

## Open question

Da li koristiti Termux bootstrap libraries kao dependency umjesto bundlati vlastiti?
Trade-off: manji APK vs bolji UX kontrola. Trenutna preporuka: embed direktno.

## Acceptance criteria

`bash` shell radi unutar app-a, možeš pokrenuti `ls`, `echo $HOME`, `pwd`.
Filesystem survives app restart. Progress screen tokom prvog extractiona.
