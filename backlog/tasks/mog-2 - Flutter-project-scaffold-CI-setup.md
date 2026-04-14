---
id: MOG-2
title: Flutter project scaffold + CI setup
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 19:53'
labels:
  - s1
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Inicijalizirati Flutter projekt sa svim dependency-ima, folder strukturom i CI pipelineom.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `flutter run` radi na Android emulatore ili fizičkom uređaju
- [x] #2 CI pipeline prolazi (flutter test + flutter build apk) na GitHub Actions
- [x] #3 Feature-first folder struktura uspostavljena (features/, core/)
- [x] #4 Svi dependency-i (riverpod, hive, dartssh2, flutter_secure_storage) instalirani
- [x] #5 Dev i prod flavor konfigurisan
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Uspostaviti feature-first folder strukturu (features/, core/)
2. Dodati sve dependencije u pubspec.yaml (riverpod, hive, dartssh2, flutter_secure_storage, xterm)
3. Kreirati dev i prod flavore
4. Kreirati GitHub Actions CI workflow (flutter test + flutter build apk)
5. Potvrditi da flutter build apk prolazi
<!-- SECTION:PLAN:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Flutter scaffold postavljen kao monorepo paket mogsh_app/.

Isporučeno:
- Dependencije: riverpod 2.6, hive, dartssh2, flutter_secure_storage, webview_flutter
- Feature-first struktura: features/{terminal,ssh,settings,onboarding}, core/{theme,storage,utils}
- AppTheme.dark: cyberpunk paleta
- Android flavori: dev (app.mogsh.terminal.dev) i prod (app.mogsh.terminal)
- GitHub Actions CI: analyze + test + build apk (build se radi na GH, ne na VPS)

AC1 (flutter run na uredjaju) verifikuje se kroz ADB tunel setup (MOG-32).
<!-- SECTION:FINAL_SUMMARY:END -->
