---
id: MOG-34
title: 'Prompt detection service: ANSI strip + PromptDetector'
status: To Do
assignee: []
created_date: '2026-04-18 19:24'
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
- [ ] #1 Create lib/core/utils/ansi.dart with stripAnsi(String) handling SGR, cursor movement, and OSC escapes
- [ ] #2 Create lib/features/terminal/services/prompt_detector.dart with PromptType enum (none/yesNo/numbered/claudeCode) and PromptOption model (key, label, color)
- [ ] #3 PromptDetector extends ChangeNotifier; attach(Stream<String>), detach(), rolling ~4000 char buffer of stripped text
- [ ] #4 Detection on last 15 lines with 150ms debounce
- [ ] #5 yesNo regex matches (y/n), [y/n], continue?, proceed?, are you sure, overwrite? case-insensitive
- [ ] #6 numbered detects >=2 consecutive lines matching ^\\s*\\d+[\\.\\)\\]]\\s+(.+)\$ followed by a prompt line; extracts labels truncated to 20 chars
- [ ] #7 claudeCode detects box-drawing + | > prompt pattern typical of Claude Code TUI
- [ ] #8 Precedence: numbered > yesNo > claudeCode > none
- [ ] #9 Detector auto-clears to none when tail no longer matches (after user input echoes)
- [ ] #10 Unit tests for ansi.dart and prompt_detector.dart with sample fixtures (rm -i, apt install, Claude Code menu, bash read loop with 1/2/3)
<!-- AC:END -->
