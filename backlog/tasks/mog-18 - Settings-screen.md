---
id: MOG-18
title: Settings screen
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s4
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Kompletne korisničke postavke, organizovane u sekcije.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Sve opcije se sačuvaju i perzistiraju kroz restart app-a
- [ ] #2 Font size live preview radi u settings ekranu
- [ ] #3 Clear credentials zahtijeva potvrdu prije brisanja
- [ ] #4 Re-provision button reinstalira dev tools uspješno
<!-- AC:END -->


## Sekcije

### Appearance
- Font family: JetBrains Mono / Fira Code / Cascadia Code
- Font size: slider 11–18px sa live preview
- Color scheme: samo "Dark Cyberpunk" u MVP (arhitektura podržava future themes)
- Terminal line height: 1.4 / 1.65 / 1.9

### Keyboard
- Swipe sensitivity: Low / Medium / High
- Haptic feedback: Off / Light / Medium
- Shortcut bar konfiguracija → link na Snippet Manager
- Quick approval mode: toggle

### Terminal
- Scrollback buffer: 1000 / 5000 / 10000 / Unlimited
- Bell: Off / Haptic / Sound
- Copy on select: toggle

### Connections
- SSH keepalive interval: 30s / 60s / 120s
- Auto-reconnect: toggle
- Mosh preference: Prefer Mosh / Always SSH
- Connection timeout: 15s / 30s / 60s

### Local Environment
- Node.js verzija + status indicator
- Python verzija + status indicator
- Re-provision button (reinstall dev tools)
- Storage usage indicator

### Security
- App lock (biometric/PIN toggle)
- SSH key management → link na Key screen
- Clear all credentials (danger zone, confirmation required)

### About
- Verzija app-a
- Changelog link
- Report bug
- Privacy policy

## Implementacija

- Sve opcije u Hive (persistent)
- Live preview za font size (mini terminal preview u settings)
- Settings changes immediate (ne treba restart)
