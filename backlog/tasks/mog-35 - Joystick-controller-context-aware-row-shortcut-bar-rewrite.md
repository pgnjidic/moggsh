---
id: MOG-35
title: Joystick controller + context-aware row (shortcut bar rewrite)
status: To Do
assignee: []
created_date: '2026-04-18 19:26'
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
- [ ] #1 Create lib/features/terminal/widgets/context_row.dart: AnimatedSize collapsible row; renders Yes/No big buttons, numbered circular 1/2/3 with labels, or Claude Code pills based on PromptContext
- [ ] #2 Context row sends option.key on tap with mediumImpact haptic; collapses to height 0 on PromptType.none
- [ ] #3 Create lib/features/terminal/widgets/joystick_controller.dart with D-pad cluster (4 arrows in cross), center voice, action cluster (Enter/Esc/Tab), and essentials strip (Ctrl+C/D/L + gear)
- [ ] #4 Button styling: _JoystickBtn helper with neumorphic-ish fill, accent border, 80ms scale+glow press animation, color-coded by function
- [ ] #5 Haptics: selectionClick on arrows, mediumImpact on action buttons, heavyImpact on Ctrl+C
- [ ] #6 Landscape compact variant of JoystickController: single 44 px row with D-pad inline, 38 px mic, action buttons inline
- [ ] #7 shortcut_bar.dart rewritten as composer: voice transcript bar + ContextRow + JoystickController; passes active tab output stream to PromptDetector instance
- [ ] #8 Remove from shortcut_bar.dart: _InputMode enum, text-input mode, _textCtrl, _textFocus, _submitText, _switchMode, _ModeToggle, _SendBtn, _textInputRow, landscape compact row, F-keys main row
- [ ] #9 MultiTabScreen passes active tab output stream into ShortcutBar; ShortcutBar detaches+reattaches PromptDetector on tab change via didUpdateWidget
- [ ] #10 On attach, replay active tab scrollbackBuffer tail (~4000 chars) into detector so context is immediate after tab switch
- [ ] #11 Snippet manager seeds F1\u2013F6 as default snippets on first launch if snippet list is empty; add 'Reset defaults' button in manager sheet
- [ ] #12 Key codes preserved (arrows, Enter \\r, Esc \\x1b, Tab \\t, Ctrl+C \\x03, Ctrl+D \\x04, Ctrl+L \\x0c)
- [ ] #13 flutter analyze lib/ clean
<!-- AC:END -->
