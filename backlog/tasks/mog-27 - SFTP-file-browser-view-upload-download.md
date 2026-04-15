---
id: MOG-27
title: 'SFTP file browser (view, upload, download)'
status: In Progress
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 20:19'
labels:
  - v1.2
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
SFTP integracija za SSH mode — pregled i transfer fajlova bez scp komandi.
Koristi istu SSH sesiju (SFTP subsystem, ne nova konekcija).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Navigiraj do `~/projects` na SSH serveru, tap na .py fajl → syntax highlighted preview
- [ ] #2 Download fajla → pojavi se u Android Downloads folderu
- [ ] #3 Upload fajla sa Androida na server radi
- [ ] #4 Progress indicator prikazan za fajlove > 1MB
<!-- AC:END -->
