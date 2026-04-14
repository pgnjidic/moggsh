---
id: MOG-20
title: Crash reporting + analytics
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
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
- [ ] #1 Simulated crash vidljiv u Sentry dashboard u < 2 minute
- [ ] #2 Events (app_opened, tool_installed, approval_used) aparaju u PostHog
- [ ] #3 Opt-out toggle zaustavi sve tracking
- [ ] #4 DSN nije hardcoded u source code-u (environment variable)
<!-- AC:END -->


## Crash reporting — Sentry

Odabir: **Sentry** (bolji Flutter support, GDPR friendly, open source, self-hostable)
Package: `sentry_flutter`

- Sentry init na app startup (DSN iz environment variable, ne hardcoded u kod)
- Automatic capture: `FlutterError.onError` + `PlatformDispatcher.onError`
- Custom context: terminal mode (local/ssh), tool running, tab count
- **Privacy**: NIKAD logirati terminal output ili SSH credentials
- User consent: opt-out u Settings → About → "Help improve mogsh"

## Analytics — PostHog

Odabir: **PostHog Cloud** (GDPR compliant, privacy-first, event-based)

Events za trackati:

| Event | Properti |
|-------|---------|
| `app_opened` | session count |
| `mode_selected` | `local` ili `ssh` |
| `tool_installed` | tool ime, `success`/`fail` |
| `ssh_connected` | `success`/`fail` |
| `approval_used` | `y` ili `n` |
| `session_duration` | sekunde |

Nema PII (personally identifiable information).

## User controls

- Opt-out toggle u Settings → About
- Opt-out disables i Sentry i PostHog
- GDPR: privacy policy URL u Settings i na Play Store listingu
