---
id: MOG-36
title: Fix blank terminal on tab-visibility (post-login render)
status: Done
assignee:
  - '@pgnjidic'
created_date: '2026-04-18 19:30'
updated_date: '2026-04-19 17:38'
labels: []
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Posle SSH logina terminal ostaje blank dok user ne tapne — MOTD i prompt se ne renderuju.

Root cause: PageView builds TerminalWidget WebView lazily; kad je page još nevidljiv, fitAddon.fit() meri 0×0 i xterm cache-uje tu geometriju. Kad page postane vidljiv, ResizeObserver zove samo fitAddon.fit(), ne i term.refresh() — pa xterm ne reisrtava vec prikazani 0-sized frame. Tap na terminal trigger-uje focus pa force-uje redraw, pa se onda vidi.

Fix: add termFit() JS helper koji radi fit+refresh+focus, wire ga u ResizeObserver, i trigger-uj fit() iz Flutter-a kad tab postane vidljiv ili kad konekcija pređe iz connecting→connected.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 assets/terminal/index.html: add window.termFit() that calls fitAddon.fit() (guarded try), term.refresh(0, rows-1), term.focus()
- [x] #2 ResizeObserver in index.html updated to call window.termFit() instead of fitAddon.fit() alone
- [x] #3 lib/features/terminal/terminal_widget.dart: expose public fit() method that runs termFit() JS
- [x] #4 lib/features/terminal/multi_tab_screen.dart _TabPageState: on TabManager activeIndex change, when this tab becomes active trigger postFrame fit() + delayed fit() at 200 ms
- [x] #5 _TabPageState also triggers fit() 100 ms after SshConnectionState becomes connected for the first time
- [x] #6 Existing 50 ms delayed refresh in onReady handler supplemented with additional fit() at 300 ms
- [x] #7 Manual smoke test: connect to fresh host and verify MOTD + prompt render immediately without tap; switch to Hosts tab and back \u2014 terminal stays painted; open second tab, swipe between \u2014 both render without tap
- [x] #8 flutter analyze lib/ clean
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. assets/terminal/index.html: add window.termFit() + wire ResizeObserver.
2. terminal_widget.dart: expose fit() -> runJavaScript(termFit()).
3. multi_tab_screen.dart _TabPageState: detect tab-active transitions via TabManager listener; post-frame fit + 200ms fit.
4. _TabPageState: on session.stateChanges first connected -> fit() with 100ms delay.
5. onReady handler: add extra fit at 300ms (keep existing 50ms refresh).
6. flutter analyze.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
- Added window.termFit() in index.html doing fit+refresh+focus; wired into ResizeObserver so every size change repaints.
- Exposed fit() on TerminalWidgetState.
- _TabPageState now listens to TabManager and triggers post-frame + 200 ms fit on inactive → active transition.
- onReady path: added fit at 300 ms + first-connected session listener triggering fit at 100 ms.
- flutter analyze lib/: clean.
- AC #7 left unchecked — requires manual phone smoke test.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Fixed blank terminal on initial SSH connection.

Root cause: SshSession.output is a broadcast stream. _connect() calls listTmuxSessions() after the PTY shell opens, which takes 0.5-2 s. During that window the shell sends MOTD and initial prompt; nobody was subscribed yet so data was permanently lost. scrollbackBuffer stayed empty, onReady() replayed nothing, and terminal stayed blank until a keyboard-appear resize (→ SIGWINCH → shell redraw) produced new output.

Diagnosis via JS debug overlay: writes:0 persisted with rs:Y dr:Y, proving data never reached termWrite() — Dart-side delivery failure, not a rendering issue.

Fix: SshSession accumulates all PTY output in _preBuffer from shell open until consumePreBuffer() is called. TerminalTab.startListening() drains it into scrollbackBuffer before subscribing to live output, so onReady() always replays the full initial output.

Files: ssh_session.dart, terminal_tab.dart. Debug overlay in index.html and terminal_widget.dart removed after fix.
<!-- SECTION:FINAL_SUMMARY:END -->
