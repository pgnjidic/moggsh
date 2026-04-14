---
id: MOG-22
title: Play Store listing (opisi, screenshots, assets)
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
Sve što treba za Play Store submission i dobru konverziju.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Internal testing build uploadan i instalabilan via Play Store
- [ ] #2 Listing draft kompletan: title, description, 4 screenshota, icon, feature graphic
- [ ] #3 Privacy policy URL živ na mogsh.app/privacy
- [ ] #4 Content rating questionnaire popunjen
<!-- AC:END -->


## Store listing (EN)

- **Title**: `mogsh — AI Coding Terminal` (max 30 chars)
- **Short description**: `AI Coding Terminal — Local & SSH` (max 80 chars)
- **Full description** (4000 chars):
  - Local mode first (zero setup, install Claude Code, start coding)
  - SSH mode second (connect to server, tmux auto-attach, Mosh)
  - Vibe coding UX differentiators (split view, approval mode, shortcut bar)
  - Competitive comparison paragraph

## Screenshots (min 4, phone 9:16)

1. Home screen — host lista sa cyberpunk kartama
2. Terminal sa Claude Code outputom + approval overlay vidljiv
3. Local mode tool installer screen
4. Shortcut bar u akciji + split view

## Tehnički assets

| Asset | Dimenzije |
|-------|-----------|
| App icon | 512×512px |
| Feature graphic | 1024×500px |
| Screenshots | min 1080×1920px |

## Administrativno

- **Content rating**: IARC questionnaire (vjerojatno "Everyone")
- **Privacy policy**: URL na `mogsh.app/privacy`, pokriva crash reports + analytics opt-out
- **Google Play Console**: internal → closed beta → open beta → production
- **Staged rollout**: 10% → 50% → 100% tokom prve sedmice

## Play Store Console setup

- Developer account aktivan (može trajati 1-2 dana verifikacija)
- Payment profile za Pro subscription
- App signing (Play App Signing — Google managed key)
