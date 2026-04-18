---
id: MOG-36
title: Fix blank terminal on tab-visibility (post-login render)
status: In Progress
assignee:
  - '@pgnjidic'
created_date: '2026-04-18 19:30'
updated_date: '2026-04-18 20:02'
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
- [ ] #7 Manual smoke test: connect to fresh host and verify MOTD + prompt render immediately without tap; switch to Hosts tab and back \u2014 terminal stays painted; open second tab, swipe between \u2014 both render without tap
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
Fixes blank terminal after SSH login / tab switch.

Root cause: PageView builds the WebView lazily; while hidden, fitAddon.fit() measures 0×0 and xterm caches that geometry. When the page becomes visible, ResizeObserver only called fitAddon.fit() — never term.refresh() — so the stale framebuffer persisted until a tap forced a focus-driven repaint.

Changes:
- assets/terminal/index.html: added window.termFit() (fit + refresh + focus) and wired it into ResizeObserver.
- terminal_widget.dart: exposed fit() that invokes termFit() via runJavaScript.
- multi_tab_screen.dart _TabPageState: listens to TabManager for active-tab transitions and triggers post-frame fit + 200 ms delayed fit; listens to session.stateChanges to fire a 100 ms fit on the first connected event; onReady now also fits at 300 ms in addition to the existing 50 ms refresh.

Tests:
- flutter analyze lib/ — clean.
- AC #7 manual smoke test pending on-device verification.
<!-- SECTION:FINAL_SUMMARY:END -->
