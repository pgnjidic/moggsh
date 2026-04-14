---
id: MOG-15
title: Split view mode (keyboard ne gura output)
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
Najvažniji UX differentiator. Keyboard NE pomjera terminal output.
Korisnik čita AI output dok tipka komandu.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Claude Code ispisuje 300 linija, korisnik skrola gore, keyboard se otvori — terminal output iznad ostaje vidljiv
- [ ] #2 Keyboard NE pomjera terminal content
- [ ] #3 FAB (Scroll to prompt) pojavi se kad korisnik nije na dnu
- [ ] #4 Tap FAB → animirani scroll do zadnjeg `❯` prompta
- [ ] #5 Expanded input mode (4 linije) dostupan via tap na input field
<!-- AC:END -->
