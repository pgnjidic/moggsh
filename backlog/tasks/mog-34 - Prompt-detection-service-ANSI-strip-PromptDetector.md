---
id: MOG-34
title: 'Prompt detection service: ANSI strip + PromptDetector'
status: Done
assignee:
  - '@pgnjidic'
created_date: '2026-04-18 19:24'
updated_date: '2026-04-18 20:22'
labels: []
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Foundation za context-aware shortcut bar. Novi servis koji sluša aktivni terminal output, strip-uje ANSI, i emit-uje PromptContext (none/yesNo/numbered/claudeCode).

Bez ovoga kontekstualni red ne može da radi. Pure Dart logic, nema UI. Testable in isolation.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Create lib/core/utils/ansi.dart with stripAnsi(String) handling SGR, cursor movement, and OSC escapes
- [x] #2 Create lib/features/terminal/services/prompt_detector.dart with PromptType enum (none/yesNo/numbered/claudeCode) and PromptOption model (key, label, color)
- [x] #3 PromptDetector extends ChangeNotifier; attach(Stream<String>), detach(), rolling ~4000 char buffer of stripped text
- [x] #4 Detection on last 15 lines with 150ms debounce
- [x] #5 yesNo regex matches (y/n), [y/n], continue?, proceed?, are you sure, overwrite? case-insensitive
- [x] #6 numbered detects >=2 consecutive lines matching ^\\s*\\d+[\\.\\)\\]]\\s+(.+)\$ followed by a prompt line; extracts labels truncated to 20 chars
- [x] #7 claudeCode detects box-drawing + | > prompt pattern typical of Claude Code TUI
- [x] #8 Precedence: numbered > yesNo > claudeCode > none
- [x] #9 Detector auto-clears to none when tail no longer matches (after user input echoes)
- [x] #10 Unit tests for ansi.dart and prompt_detector.dart with sample fixtures (rm -i, apt install, Claude Code menu, bash read loop with 1/2/3)
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. lib/core/utils/ansi.dart — stripAnsi util with SGR / cursor / OSC regexes.
2. lib/features/terminal/services/prompt_detector.dart — PromptType, PromptOption, PromptContext, PromptDetector (ChangeNotifier, debounced, rolling buffer).
3. Detection rules for yesNo / numbered / claudeCode with precedence numbered > yesNo > claudeCode > none.
4. Auto-clear when tail no longer matches a prompt.
5. Unit tests covering ansi.dart + detector fixtures (rm -i, apt install, Claude Code TUI, numbered bash read).
6. flutter analyze + flutter test.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
- Created lib/core/utils/ansi.dart with stripAnsi() handling OSC, CSI, 2-byte intermediates, and any remaining ESC+printable single-char sequence.
- Created lib/features/terminal/services/prompt_detector.dart with PromptType, PromptOption, PromptContext, and PromptDetector (ChangeNotifier, 150 ms debounce, 8000-char rolling buffer, last 15 lines scanned).
- yesNo scans only the last 2 non-empty lines so old prompts that scroll away no longer re-trigger.
- numbered requires ≥2 consecutive numbered lines + awaiting prompt line; precedence numbered > yesNo > claudeCode > none.
- claudeCode detects box-drawing + trailing | or > prompt line.
- attach() optional seed primes detector from scrollback tail.
- 23 unit tests pass (ansi_test.dart + prompt_detector_test.dart).
- flutter analyze lib/ test/: clean.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Foundation for context-aware shortcut bar.

Adds a pure-Dart prompt-detection layer that watches a terminal output Stream, strips ANSI, and infers whether the tail represents an interactive prompt.

Changes:
- lib/core/utils/ansi.dart — stripAnsi() removes OSC (BEL/ST terminated), CSI, charset-selection, and remaining single-byte ESC sequences while preserving \r/\n/\t.
- lib/features/terminal/services/prompt_detector.dart — PromptType {none, yesNo, numbered, claudeCode}, PromptOption (key/label/color/hint), PromptContext, PromptDetector (ChangeNotifier). Debounced (150 ms) detection over a rolling 8000-char buffer; precedence numbered > yesNo > claudeCode > none; detach() and dispose() clear state; attach() accepts an optional seed for scrollback priming.
- test/ansi_test.dart, test/prompt_detector_test.dart — 23 unit tests covering rm -i, apt, overwrite?, Continue?, bash read 1/2/3 menu, label truncation, precedence, single numbered line (none), Claude Code TUI, auto-clear after answer, detach(), and seed priming.

Tests:
- flutter analyze lib/ test/ — clean.
- flutter test test/ansi_test.dart test/prompt_detector_test.dart — 23/23 pass.
<!-- SECTION:FINAL_SUMMARY:END -->
