---
id: MOG-35
title: Joystick controller + context-aware row (shortcut bar rewrite)
status: Done
assignee:
  - '@pgnjidic'
created_date: '2026-04-18 19:26'
updated_date: '2026-04-19 07:46'
labels: []
dependencies:
  - MOG-34
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Shortcut bar prestaje da bude tastatura i postaje gamepad. Tri zone: kontekstualni red koji reaguje na prompt (Y/N, 1/2/3, Claude Code), glavni joystick red (D-pad levo, mic sredina, akcije desno), i always-on red (Ctrl+C, Ctrl+D, Ctrl+L, snippets).

Remove: keyboard toggle, text-input mode, F1–F6 sa glavnog bara (premestaju se u snippet defaults).
Keep: voice button prominentan, transcript bar, snippet manager, landscape FAB nav, compact tab bar.

Portrait: 3 reda (context 0–50 px + joystick 88 px + essentials 44 px).
Landscape: 2 reda (context + single combined 44 px).

Zavisi od MOG-34 (prompt detector) za kontekstualni red.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Create lib/features/terminal/widgets/context_row.dart: AnimatedSize collapsible row; renders Yes/No big buttons, numbered circular 1/2/3 with labels, or Claude Code pills based on PromptContext
- [x] #2 Context row sends option.key on tap with mediumImpact haptic; collapses to height 0 on PromptType.none
- [x] #3 Create lib/features/terminal/widgets/joystick_controller.dart with D-pad cluster (4 arrows in cross), center voice, action cluster (Enter/Esc/Tab), and essentials strip (Ctrl+C/D/L + gear)
- [x] #4 Button styling: _JoystickBtn helper with neumorphic-ish fill, accent border, 80ms scale+glow press animation, color-coded by function
- [x] #5 Haptics: selectionClick on arrows, mediumImpact on action buttons, heavyImpact on Ctrl+C
- [x] #6 Landscape compact variant of JoystickController: single 44 px row with D-pad inline, 38 px mic, action buttons inline
- [x] #7 shortcut_bar.dart rewritten as composer: voice transcript bar + ContextRow + JoystickController; passes active tab output stream to PromptDetector instance
- [x] #8 Remove from shortcut_bar.dart: _InputMode enum, text-input mode, _textCtrl, _textFocus, _submitText, _switchMode, _ModeToggle, _SendBtn, _textInputRow, landscape compact row, F-keys main row
- [x] #9 MultiTabScreen passes active tab output stream into ShortcutBar; ShortcutBar detaches+reattaches PromptDetector on tab change via didUpdateWidget
- [x] #10 On attach, replay active tab scrollbackBuffer tail (~4000 chars) into detector so context is immediate after tab switch
- [x] #11 Snippet manager seeds F1\u2013F6 as default snippets on first launch if snippet list is empty; add 'Reset defaults' button in manager sheet
- [x] #12 Key codes preserved (arrows, Enter \\r, Esc \\x1b, Tab \\t, Ctrl+C \\x03, Ctrl+D \\x04, Ctrl+L \\x0c)
- [x] #13 flutter analyze lib/ clean
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create context_row.dart — AnimatedSize + renders per PromptContext (Yes/No pair, numbered chips, claudeCode pills).
2. Create joystick_controller.dart — _JoystickBtn helper + portrait (D-pad / mic / action cluster / essentials strip) + landscape single-row variant.
3. Rewrite shortcut_bar.dart as composer (voice transcript bar + ContextRow + JoystickController); owns PromptDetector lifecycle; removes text-input mode, F-keys, keyboard toggle.
4. Wire MultiTabScreen to pass active tab output stream + scrollback seed to ShortcutBar (detach/reattach on tab change via didUpdateWidget).
5. Seed F1–F6 as default snippets on first launch; add Reset defaults button in snippet sheet.
6. flutter analyze lib/.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
- Created context_row.dart — AnimatedSize collapsing to 0 on PromptType.none; renders big pill Yes/No, circular numbered buttons with label hints, or Claude Code pills. Haptics mediumImpact on tap, press-scale + glow animation.
- Created joystick_controller.dart — portrait: D-pad stack, center voice, Enter/Esc/Tab cluster, essentials strip (Ctrl+C/D/L + gear). Landscape: single 44 px row with D-pad inline + compact voice. _JoystickBtn handles 80 ms press scale 0.92 + glow, color-coded per function; heavyImpact on Ctrl+C, mediumImpact on actions, selectionClick on arrows/gear.
- Rewrote shortcut_bar.dart as composer: VoiceInputService + PromptDetector + snippet storage only. Keeps voice transcript bar and _VoiceBtn (amplitude-driven glow); removes _InputMode / text input / _ModeToggle / _SendBtn / _KeyBtn / _IconBtn / F-keys row / landscape compact key row.
- On first launch F1–F6 are seeded as default snippets (flag snippets_seeded_v1 prevents re-seeding); snippet sheet now has tap-to-send, Reset defaults confirm dialog, and readable preview of escape sequences.
- multi_tab_screen.dart passes mgr.activeTab.output + scrollback tail (4000 chars) to ShortcutBar; ShortcutBar detaches + reattaches detector in didUpdateWidget on tab change.
- Key codes preserved unchanged (arrows \x1b[A/B/C/D, Enter \r, Esc \x1b, Tab \t, Ctrl+C \x03, Ctrl+D \x04, Ctrl+L \x0c).
- flutter analyze lib/ test/: clean. Existing 23 MOG-34 tests still pass; widget_test.dart failure pre-existed on main (Hive init unrelated to this change).
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Rewrites the shortcut bar into a three-band gamepad composer.

What changed:
- New widget ContextRow (AnimatedSize) surfaces big context buttons driven by PromptDetector: Yes/No for y/n prompts, numbered circular buttons with extracted labels for bash read menus, Send/Multiline/Esc pills for Claude Code TUI. Collapses to height 0 when PromptType.none.
- New widget JoystickController replaces the legacy key row: D-pad cross, prominent voice button, action cluster (Enter / Esc / Tab), and always-on essentials strip (Ctrl+C, Ctrl+D, Ctrl+L, snippet gear). Landscape renders the same controls in a single 44 px row so landscape keeps screen height for the terminal.
- ShortcutBar is now a thin composer: voice transcript bar + ContextRow + JoystickController; owns PromptDetector and detaches/reattaches on tab change via didUpdateWidget, priming with the active tab scrollback tail so context is immediate after switching.
- F1–F6 are seeded as default snippets on first launch (using a snippets_seeded_v1 flag) so power users still have them; the snippet sheet now supports tap-to-send and Reset to defaults with confirmation.
- MultiTabScreen passes activeTab.output + 4000-char scrollback seed to ShortcutBar.

Removed:
- _InputMode enum, text input mode, _textCtrl/_textFocus, _submitText/_switchMode, _ModeToggle, _SendBtn, _textInputRow.
- _row1 / _row2 static key lists, _KeyBtn, _IconBtn, F-keys main row, legacy landscape compact key row.

UX notes:
- Haptics: selectionClick on arrows, mediumImpact on action buttons, heavyImpact on Ctrl+C, mediumImpact on context buttons, mediumImpact when toggling the mic.
- Key codes unchanged: arrows \x1b[A/B/C/D, Enter \r, Esc \x1b, Tab \t, Ctrl+C \x03, Ctrl+D \x04, Ctrl+L \x0c.

Tests:
- flutter analyze lib/ test/ — clean.
- flutter test test/ansi_test.dart test/prompt_detector_test.dart — 23/23 pass.
- widget_test.dart pre-existing Hive failure on main is unrelated.
<!-- SECTION:FINAL_SUMMARY:END -->
