---
id: MOG-2
title: Flutter project scaffold + CI setup
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s1
dependencies: []
priority: medium
---

## Opis

Inicijalizirati Flutter projekt sa svim dependency-ima, folder strukturom i CI pipelineom.

## Zadaci

- Flutter project init (`app.mogsh.terminal`, minSdkVersion 26+)
- Feature-first folder struktura:
  ```
  lib/
    features/terminal/  features/ssh/  features/local/  features/settings/
    core/design_system/  core/storage/  core/services/
  ```
- Dependencies:
  - `riverpod` — state management
  - `hive` + `hive_flutter` — local DB (profili, snippeti, settings)
  - `flutter_secure_storage` — SSH ključevi
  - `dartssh2` — SSH protokol
  - `local_auth` — biometrija
- Linting: `flutter_lints` + custom `analysis_options.yaml`
- GitHub Actions CI: `flutter test` + `flutter build apk` na svaki PR
- Flavors: `dev` i `prod` (različiti package names, različite ikone)
- Semantic versioning: `1.0.0+1`

## Acceptance criteria

`flutter run` radi na Android emulator, CI prolazi, folder struktura uspostavljena,
svi dependency-i instalirani i importabilni.
