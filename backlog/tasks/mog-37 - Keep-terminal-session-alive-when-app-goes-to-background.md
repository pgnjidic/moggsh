---
id: MOG-37
title: Keep terminal session alive when app goes to background
status: Done
assignee:
  - '@agent'
created_date: '2026-04-19 08:44'
updated_date: '2026-04-19 08:53'
labels:
  - android
  - session
  - ssh
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
SSH session gets killed when user switches to another app. The foreground service infrastructure already exists (TerminalForegroundService.kt registered in manifest, startForeground/stopForeground MethodChannel in MainActivity), but Dart never invokes it. Fix: wire up WidgetsBindingObserver in Flutter to start the foreground service when app goes to background (AppLifecycleState.paused) and stop it when resumed. Also ensure SSH keepalive is sent so the server doesn't time out the idle connection.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 App switching to background starts the Android foreground service (persistent notification visible)
- [x] #2 SSH session remains connected after 60+ seconds in background
- [x] #3 Returning to app restores the terminal without reconnecting
- [x] #4 Foreground service stops when all terminal tabs are closed
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. HomeScreen: dodati WidgetsBindingObserver mixin
2. didChangeAppLifecycleState: paused + aktivni tabovi → startForeground; resumed → stopForeground
3. _tabManager.addListener: kad tabs.isEmpty → stopForeground
4. dartssh2 keepAliveInterval je već 10s po defaultu — nema šta da se menja
5. Testirati: ići u background 60s, vratiti se — sesija živa
<!-- SECTION:PLAN:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Wired Android foreground service to Flutter lifecycle via WidgetsBindingObserver in HomeScreen.

Changes:
- HomeScreen now mixes in WidgetsBindingObserver
- didChangeAppLifecycleState: on paused (with active tabs) → startForeground; on resumed → stopForeground
- _tabManager listener: when last tab closes → stopForeground
- dartssh2 keepAliveInterval already defaults to 10s — no change needed

The TerminalForegroundService (START_STICKY, persistent notification) was already registered in AndroidManifest; this commit activates it.
<!-- SECTION:FINAL_SUMMARY:END -->
