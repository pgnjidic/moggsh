---
id: MOG-23
title: Agent completion notifications
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
Notifikacija kada AI agent završi task — korisnik može odložiti telefon i dobiti ping.
Nema potrebe stare u ekran dok Claude Code radi.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Pokreni agent task, minimizuj app → notifikacija stigne < 3s od completion
- [ ] #2 Tap notifikacije → otvori terminal tab na zadnji output
- [ ] #3 Quiet hours: nema notifikacije u postavljenom periodu
- [ ] #4 Toggle per-tab radi (samo označeni tabovi šalju notifikacije)
<!-- AC:END -->


## Pattern detection service

Background thread sluša terminal output per aktivan tab:

```
Trigger patterns:
  ❯           ← prompt return nakon dugog outputa (primary signal)
  Task completed / Done! / All done
  Claude Code: specifični completion patterns
  Aider: commit message output
```

- Debounce: 2 sekunde tišine nakon pattern match → fire notification
- Anti-spam: ne fire ako je korisnik aktivno u app-u (foreground)
- Korisnik može dodati custom patterns u Settings

## Android Notification

- `NotificationChannel`: "Agent Activity" (importance: DEFAULT, ne HIGH)
- Content: `[Project name] — Agent finished`
- Actions u notifikaciji: **Open** + **View Output** (deep link direktno u tab)
- Skupljanje: 3+ notifikacije za isti tab → jedna summary
- Scheduled Do Not Disturb aware

## Settings → Notifications

- Toggle per-tab ili globalno
- Quiet hours (npr. 22:00–08:00)
- Custom completion patterns

## Pro feature

- Free: notifikacije na 1 tabu
- Pro: unlimited tabova
