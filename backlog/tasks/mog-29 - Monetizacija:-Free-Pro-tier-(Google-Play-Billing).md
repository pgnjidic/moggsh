---
id: MOG-29
title: Monetizacija: Free/Pro tier (Google Play Billing)
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - infra
dependencies: []
priority: medium
---

## Opis

Freemium model sa Google Play Billing. Cilj: konverzija power usera koji
zaista koriste app, bez agresivnih paywalla koji alieniraju nove korisnike.

## Pro features (locked za free tier)

| Feature | Free | Pro |
|---------|------|-----|
| SSH server profili | max 2 | unlimited |
| Custom snippeti | max 5 | unlimited |
| Mosh podrška | — | ✓ |
| SFTP browser | — | ✓ |
| Git panel | — | ✓ |
| Voice input | 50/dan | unlimited |
| Agent notifications | 1 tab | unlimited |
| Home screen widget | 1 server | unlimited |
| Themes (buduće) | — | ✓ |

## Google Play Billing

Package: `in_app_purchase` Flutter

SKU-ovi:
- `mogsh_pro_monthly`: $4.99/mj
- `mogsh_pro_yearly`: $39.99/god (~33% popust)
- `mogsh_pro_lifetime`: $79.99 (early bird)

Server-side receipt validation (Play Developer API).
Grace period: 7 dana za expired subscription (ne zaključavaj odmah).
Restore purchases: dugme u Settings za restore pri reinstalaciji.

## Paywall UX

- NE agresivni paywalls — bottom sheet sa pricing na Pro feature tap
- Trial: 7 dana Pro besplatno na onboardingu (bez kreditne kartice)
- Pro badge: subtilni `PRO` pill u Settings header-u

## Acceptance criteria

Subscription flow radi u Play Store sandbox okruženju.
Pro features dostupne odmah nakon purchase.
Free tier ograničenja enforced.
Restore purchases radi na reinstalaciji.
