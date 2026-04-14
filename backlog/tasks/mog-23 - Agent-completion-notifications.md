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

## Opis

Notifikacija kada AI agent završi task — korisnik može odložiti telefon i dobiti ping.
Nema potrebe stare u ekran dok Claude Code radi.

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

## Acceptance criteria

Pokreni `claude` task, minimizuj app, čekaj completion → notifikacija stigne < 3s.
Tap → otvori terminal tab na zadnji output. Quiet hours: nema notifikacije u periodu.
