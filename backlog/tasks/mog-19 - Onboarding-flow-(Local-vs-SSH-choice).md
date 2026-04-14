---
id: MOG-19
title: Onboarding flow (Local vs SSH choice)
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s5
dependencies: []
priority: medium
---

## Opis

First-run iskustvo koje dovede korisnika do prvog "wow" momenta što brže moguće.
Cilj: < 5 minuta od install-a do `claude` koji radi.

## Screens

### Screen 1 — Welcome
- mogsh logo + tagline: "Vibe code from your phone."
- "Get started" button

### Screen 2 — Choose your mode
- Dvije kartice:
  - **LOCAL** (highlighted, recommended): "No server needed. Code with AI agents right on your phone." Bullet: Claude Code / Aider / Codex, Node.js + Python built-in, Start in 2 minutes
  - **SSH REMOTE**: "Connect to your server or VPS." Bullet: Full SSH client, tmux auto-attach, Mosh support
- "I'll do both" opcija

### Local path
1. "Setting up your environment" (auto-provisioning progress, ~2-3 min)
2. "Install your AI tool" (tool installer kartice — Claude Code highlighted)
3. Auth flow za odabrani tool
4. → Terminal sa welcome messagom

### SSH path
1. Add server forma (pojednostavljen: host, username, auth)
2. Quick test konekcija
3. → Terminal

## UX detalji

- Skip opcija na svakom ekranu (power users)
- Deep link za preskakanje: `mogsh://skip-onboarding` (dev/testing)
- Progress indicator (dots ili steps) tokom cijelog flowa
- Error recovery: ako provisioning faili → retry screen, ne black screen

## Acceptance criteria

Fresh install → onboarding → Local path → Claude Code instaliran i autentificiran
→ `claude` radi u terminalu. Cijeli flow < 5 minuta za prosječnog korisnika.
Skip radi na svakom koraku.
