---
id: MOG-11
title: Server profili CRUD (lokalni storage)
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:16'
labels:
  - s3
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Upravljanje saved server konfiguracijama — Home screen je ovo.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Dodaj server → pojavi se u listi → tap → konekcija uspostavljena
- [x] #2 Edit mijenja podatke, Delete uklanja profil
- [x] #3 Export/import round-trip radi (JSON backup)
- [x] #4 Startup script se izvršava automatski na connect
- [x] #5 Quick-connect < 3s od tapa do otvorene sesije
<!-- AC:END -->
