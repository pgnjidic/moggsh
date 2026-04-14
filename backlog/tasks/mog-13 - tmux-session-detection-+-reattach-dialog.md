---
id: MOG-13
title: tmux session detection + reattach dialog
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s3
dependencies: []
priority: medium
---

## Opis

Automatski detektuj tmux sesije odmah nakon SSH konekcije i ponudi reattach.
Nikad više ručni `tmux attach`.

## Detection flow

Odmah nakon SSH konekcije, prije spawn shell-a:

```bash
tmux list-sessions -F "#{session_name}|#{session_windows}|#{session_attached}" 2>/dev/null
```

- Postoje sesije → prikaži Session Picker bottom sheet
- Nema sesija → direktno spawna shell

## Session Picker UI (bottom sheet)

- Lista sesija: ime, broj windows, attached/detached status badge
- Detached sesija: neon border (klikabilna za reattach)
- Attached sesija: dimovana (ali može force-attach)
- "New session" opcija
- "Raw shell (no tmux)" opcija
- Auto-select: jedna detached sesija → automatski highlighted kao default

## Komande

- Reattach: `tmux attach-session -t <session_name>`
- New session: `tmux new-session -s mogsh-<timestamp>`

## Per-server startup script

Ako server profil ima `startupScript` → izvršava se umjesto session picker-a.
Npr: `cd ~/myproject && tmux attach -t dev || tmux new -s dev`

## Acceptance criteria

SSH na server sa 2 tmux sesije → bottom sheet sa obje → tap → reattach.
Terminal prikazuje tmux. Server bez tmux-a → direktan shell bez dijaloga.
