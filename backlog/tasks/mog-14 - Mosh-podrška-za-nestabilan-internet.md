---
id: MOG-14
title: Mosh podrška za nestabilan internet
status: In Progress
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
Mosh (Mobile Shell) je UDP-based protokol koji preživljava IP promjene, kratke
pauze interneta i sleep/wake cikluse. Idealan za mobilni razvoj.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Konekcija via Mosh uspostavljena kad je mosh-server dostupan
- [ ] #2 Airplane mode 10s → automatski reconnect bez gubitka sesije
- [ ] #3 'Connected via Mosh' badge vidljiv u tab bar-u
- [ ] #4 Fallback na SSH ako mosh nije dostupan na serveru
<!-- AC:END -->
