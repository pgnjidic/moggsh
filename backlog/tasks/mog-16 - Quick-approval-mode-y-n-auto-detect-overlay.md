---
id: MOG-16
title: Quick approval mode (y/n auto-detect overlay)
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:16'
labels:
  - s4
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Kada AI agent traži potvrdu, prikaži veliki Y/N overlay umjesto tipkanja.
Jedan tap umjesto tipkanja `y` + Enter.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Claude Code ispiše '(y/n)' → approval banner se pojavi u < 500ms
- [ ] #2 Tap Y → odgovor poslan, agent nastavlja
- [ ] #3 Tap N → negativan odgovor poslan
- [ ] #4 False positive → dismiss bez slanja radi
- [ ] #5 Toggle za isključivanje feature-a u Settings radi
<!-- AC:END -->
