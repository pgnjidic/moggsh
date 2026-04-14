---
id: MOG-11
title: Server profili CRUD (lokalni storage)
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:13'
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
- [ ] #1 Dodaj server → pojavi se u listi → tap → konekcija uspostavljena
- [ ] #2 Edit mijenja podatke, Delete uklanja profil
- [ ] #3 Export/import round-trip radi (JSON backup)
- [ ] #4 Startup script se izvršava automatski na connect
- [ ] #5 Quick-connect < 3s od tapa do otvorene sesije
<!-- AC:END -->
