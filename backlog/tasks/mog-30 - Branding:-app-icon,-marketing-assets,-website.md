---
id: MOG-30
title: Branding: app icon, marketing assets, website
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - infra
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Vizualni identitet mogsh branda. Cyberpunk aesthetic konzistentan sa app-om.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 App icon uploadan u Play Console (512x512px)
- [ ] #2 Feature graphic i 4 screenshota uploadan
- [ ] #3 mogsh.app landing page živ sa Play Store badge-om i email signup-om
- [ ] #4 Privacy policy URL aktivan (potrebno za Play Store submission)
<!-- AC:END -->


## App Icon

- 512×512px za Play Store + adaptive icon (foreground + background layer)
- Concept: stilizovani terminal prompt `❯` u neon cyan na void crnoj pozadini
- Čitljiv na 48px (launcher) i 512px (store) — ne detaljan, čist
- Originalni dizajn, nije stock

## Play Store assets

| Asset | Dimenzije |
|-------|-----------|
| Feature graphic | 1024×500px |
| Phone screenshots (min 4) | 1080×1920px |

Screenshot sadržaj:
1. Home screen — host lista, cyberpunk kartice
2. Terminal sa Claude Code outputom + approval overlay
3. Local mode tool installer
4. Shortcut bar + split view

## Social media

- Twitter/X header: 1500×500px
- Product Hunt logo: 240×240px
- Launch teaser copy: "Other terminals just got mogged."

## Website — mogsh.app

Single page landing (ne SPA framework, plain HTML/CSS):
- Hero: tagline + Play Store badge
- Feature bullets: Local mode, SSH mode, vibe coding UX
- Screenshot carousel
- Email signup za launch updates
- Cyberpunk aesthetic konzistentan sa app-om
- Privacy policy stranica (`/privacy`)

## Launch copy (za koristiti svuda)

```
Tagline:      "Vibe code from your phone. No server needed."
Hook:         "Other terminals just got mogged."
Play Store:   "AI Coding Terminal — Local & SSH"
Product Hunt: "mogsh — Vibe coding terminal for Android"
```
