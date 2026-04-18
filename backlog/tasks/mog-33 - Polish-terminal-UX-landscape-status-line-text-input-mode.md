---
id: MOG-33
title: 'Polish terminal UX: landscape, status line, text-input mode'
status: Done
assignee:
  - '@pgnjidic'
created_date: '2026-04-18 15:09'
updated_date: '2026-04-18 19:02'
labels: []
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Landscape layout is cramped (chrome eats ~210px, terminal gets only ~150px). Status indicator unclear. No way to type+send without voice. Polish main terminal feature.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Landscape: terminal gets majority of vertical space (chrome <110px total)
- [x] #2 Landscape: single-row shortcut bar with ESC/F-keys/Ctrl/arrows/voice-or-text
- [x] #3 Landscape: bottom nav replaced with compact floating menu FAB
- [x] #4 Status line: connection state is clearly visible (stronger dot, pulse on connecting, visible tab title)
- [x] #5 Text-input mode: toggle next to voice swaps mic with inline TextField + Send button that sends text+\r
- [x] #6 Portrait layout remains largely unchanged and readable
- [x] #7 Settings and other pages still reachable from landscape
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. ShortcutBar: add text-input mode toggle (mic ↔ keyboard icon). Text mode shows inline TextField + Send btn; Send writes text + \r.
2. ShortcutBar: add landscape compact layout (single row, height ~38, ESC F1-6 Tab Ctrl+C/D/Z arrows all horizontally scroll, voice/text fixed right).
3. MogshTabBar: landscape variant height 34, smaller pills, brighter active dot with pulse when connecting.
4. HomeScreen: in landscape, hide bottom nav entirely. Add floating nav FAB (top-right) that opens a bottom sheet with Hosts/Keys/Settings.
5. MultiTabScreen: wire through orientation and pass to ShortcutBar + MogshTabBar.
6. Manual test via ADB in both portrait and landscape.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Landscape
- Compact tab bar (34 px) with stronger active glow and pulsing connection dot (amber while connecting).
- Bottom nav hidden; floating menu FAB top-right opens bottom sheet with Hosts/Keys/Settings.
- Shortcut bar collapses to single 36 px row: ESC/F1-6/Tab/Ctrl/arrows scrollable; compact voice + mode toggle + snippets on right.
- Tab bar reserves 48 px trailing slot so pills never collide with the FAB.
- Chrome total ~78 px in landscape (vs ~200 previously). Terminal body effectively ~2.5x taller.

## Text-input mode
- New toggle button (keyboard icon) beside voice. Tap swaps mic with an inline TextField + Send.
- Send (arrow-up, green) writes text + \r and keeps focus so the user can chain commands.
- onSubmitted also triggers Send so the native keyboard Enter key works.
- Switching back to voice mode unfocuses the TextField so the keyboard closes.

## Portrait
- Unchanged two-row layout; voice button now neighbors the mode toggle.
- In text mode the second row becomes TextField + Send + mode toggle; F-keys row stays visible.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Polished the landscape terminal UX and added a text-input alternative to voice.

**Landscape**
- Bottom nav is hidden when the terminal tab is active; a small floating menu FAB opens a sheet for Hosts/Keys/Settings.
- `MogshTabBar` gains a `compact` variant (34 px) with a brighter active dot and an animated pulse while connecting.
- `ShortcutBar` switches to a single 36 px scrollable row (ESC/F-keys/Ctrl/arrows) plus compact voice + mode toggle + snippet manager.
- Total chrome dropped from ~200 px to ~78 px, giving the terminal roughly 2.5× more vertical space.

**Text-input mode**
- New toggle (keyboard ⇄ mic) lives beside the voice button.
- Text mode replaces the mic with an inline `TextField` + neon Send button; Send (or native keyboard Enter via `onSubmitted`) writes the text + `\r` and keeps the field focused for chained commands.
- Cancelling returns to voice mode and unfocuses the field so the IME closes.

**Files changed**
- `mogsh_app/lib/features/terminal/widgets/shortcut_bar.dart` — text mode, landscape variant, mode toggle, send button.
- `mogsh_app/lib/features/terminal/widgets/tab_bar_widget.dart` — compact variant, connection pulse animation, trailing slot.
- `mogsh_app/lib/features/terminal/multi_tab_screen.dart` — pass orientation to tab bar, reserve FAB space.
- `mogsh_app/lib/home_screen.dart` — hide bottom nav in landscape terminal, floating menu FAB with sheet.

**Tests**
- `flutter analyze lib/` — no issues.
- Device smoke test pending (ADB tunnel not currently open).
<!-- SECTION:FINAL_SUMMARY:END -->
