---
id: MOG-1
title: Project kickoff & open decisions
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s1
dependencies: []
priority: medium
---

## Opis

Razriješiti sve otvorene odluke prije nego što dev počne. Svaka nerješena odluka
blokira ili usporava sprint 1.

## Odluke za donijeti

1. **Domain** — potvrditi registraciju `mogsh.app`

2. **proot vs Termux plugin**
   - Option A: embedamo proot direktno u Flutter app (bolji UX, sve u jednom, veći APK)
   - Option B: Termux:API kao external dependency (brže do MVP, ali external dep, loš UX)
   - Preporuka: Option A — kontrola nad cijelim stack-om

3. **Onboarding flow** — "Choose your mode": Local (default, highlighted) vs SSH

4. **Storage za lokalne projekte**
   - Option A: internal storage only (sigurnije)
   - Option B: external/SD card only (više prostora)
   - Option C: korisnik bira (best UX)
   - Preporuka: Option C

5. **Free tier granice**
   - Option A: Local unlimited + SSH max 2 servera free
   - Option B: sve free + reklame, Pro bez reklama + premium features
   - Razmotriti: šta tjera konverziju u Pro? Serveri ili features?

6. **Flutter terminal performance** — benchmarkirati `flutter_pty` vs `xterm` package
   na 200+ linija AI outputa, mid-range Android (Snapdragon 665, 4GB RAM)

7. **Flutter projekt struktura** — feature-first folder layout:
   ```
   lib/
     features/
       terminal/
       ssh/
       local/
       settings/
     core/
       design_system/
       storage/
   ```

8. **Package name** — potvrditi: `app.mogsh.terminal`

9. **Play Store developer account** — setup i verifikacija (može trajati 1-2 dana)

10. **Crash reporting** — Sentry vs Firebase Crashlytics
    - Preporuka: Sentry (bolji Flutter support, GDPR friendly, open source)

## Deliverables

- [ ] ADR dokument (Architecture Decision Records) za svaku odluku
- [ ] Flutter projekt inicijaliziran na GitHubu
- [ ] mogsh.app registrovan
- [ ] Play Store developer account aktivan

## Acceptance criteria

Sve odluke dokumentovane, tim aligned, projekt na Githu, domain radi.
