---
id: MOG-2
title: Flutter project scaffold + CI setup
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 19:01'
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
- [ ] #2 CI pipeline prolazi (flutter test + flutter build apk) na GitHub Actions
- [ ] #3 Feature-first folder struktura uspostavljena (features/, core/)
- [ ] #4 Svi dependency-i (riverpod, hive, dartssh2, flutter_secure_storage) instalirani
- [ ] #5 Dev i prod flavor konfigurisan
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Uspostaviti feature-first folder strukturu (features/, core/)
2. Dodati sve dependencije u pubspec.yaml (riverpod, hive, dartssh2, flutter_secure_storage, xterm)
3. Kreirati dev i prod flavore
4. Kreirati GitHub Actions CI workflow (flutter test + flutter build apk)
5. Potvrditi da flutter build apk prolazi
<!-- SECTION:PLAN:END -->
