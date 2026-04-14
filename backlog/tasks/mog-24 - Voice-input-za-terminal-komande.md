---
id: MOG-24
title: Voice input za terminal komande
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - v1.1
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Android Speech-to-Text integracija za hands-free terminal input.
Koristan za duže promptove — izgovoриш umjesto tipkaš.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Hold voice button, izgovori 'git status' → komanda se pojavi u input field
- [ ] #2 Release → šalje se u terminal
- [ ] #3 Radi offline sa downloaded Google STT modelom
- [ ] #4 'slash plan' izgovoreno → `/plan` u inputu
<!-- AC:END -->


## Voice button (po design sistemu)

- 48×48px kružni button u shortcut baru (center Row 3)
- Neon glow: `radial-gradient(circle, #00ffaa30, #00ffaa10)`, border `#00ffaa60`
- Tap → start listening, tap again → stop i send
- Hold → push-to-talk mode
- Active state: glow ring pulses outward

## Android STT integracija

- `SpeechRecognizer` API (native Android, offline mode gdje dostupno)
- Interim results: prikazuj u input field dok govoriš (dim tekst)
- Final result: normalni tekst u input field, korisnik može editovati prije slanja
- Auto-send opcija (Settings toggle): automatski šalje nakon pauze

## Terminal-aware vocabulary

- Custom hints: "claude", "git", "npm", "sudo", "python", "slash", "pipe"
- "/" prefix: izgoвориш "slash plan" → insert `/plan`
- Offline STT: Google offline model (provjeri na startup, upozori ako nije downloaded)

## Pro feature

- Free: 50 voice commands/dan
- Pro: unlimited
