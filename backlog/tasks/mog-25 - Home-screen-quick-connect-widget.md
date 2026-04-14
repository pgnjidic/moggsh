---
id: MOG-25
title: Home screen quick-connect widget
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - v1.1
dependencies: []
priority: medium
---

## Opis

Android App Widget za brzi pristup omiljenim serverima/projektima direktno sa home screena.

## Widget varijante

| Varijanta | Dimenzije | Sadržaj |
|-----------|-----------|---------|
| Small | 2×1 | Jedna kartica servera |
| Medium | 4×1 | 3 servera u redu + "+" |
| Large | 4×2 | Do 6 servera sa status dotovima |

## Ponašanje

- Status dots refresh: svakih 30 min (Android widget battery constraint)
- Kad app nije aktivan: ne vrtimo SSH connections za status check
- Tap na server → `mogsh://connect/<server-id>` → app se otvori, konekcija počne automatski

## Widget konfiguracija

- Long press → odaberi koji serveri se prikazuju
- Color theme: prati app dark theme (cyberpunk)

## Pro feature

- Free: max 1 server na widget-u (ostali su placeholder za upgrade)
- Pro: sve varijante, unlimited servera

## Acceptance criteria

Dodaj medium widget na home screen, prikazuje 3 servera, tap na jedan →
app se otvori i počne konekciju automatski. Free tier: samo 1 server vidljiv.
