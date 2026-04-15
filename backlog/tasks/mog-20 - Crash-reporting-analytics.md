---
id: MOG-20
title: Crash reporting + analytics
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-15 06:45'
labels:
  - s5
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Observability za production app. Znati šta se crasha i koje featurese korisnici koriste.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Simulated crash vidljiv u Sentry dashboard u < 2 minute
- [x] #2 Events (app_opened, tool_installed, approval_used) aparaju u PostHog
- [x] #3 Opt-out toggle zaustavi sve tracking
- [x] #4 DSN nije hardcoded u source code-u (environment variable)
<!-- AC:END -->
