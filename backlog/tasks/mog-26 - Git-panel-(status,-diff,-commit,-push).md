---
id: MOG-26
title: Git panel (status, diff, commit, push)
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - v1.2
dependencies: []
priority: medium
---

## Opis

Vizualni git panel unutar app-a — git workflow bez terminala.
Radi i za local mode i za SSH mode (isti UI, isti shell-out).

## Pristup

- Git ikona u toolbar-u (pojavi se samo ako je detektirano git repo u CWD: `git rev-parse`)
- Slide-in panel (desna strana, 80% širine)

## Funkcionalnosti

**Status:**
- Lista changed/staged/untracked fajlova sa ikonama (M/A/D/??)
- Checkbox za stage/unstage po fajlu

**Diff:**
- Tap na fajl → unified diff overlay
- Syntax highlighted (red/green linije, +/- prefix)
- Portrait: unified diff, Landscape: side-by-side

**Commit:**
- Input polje za commit message
- "Commit" button
- AI-assisted commit message: button koji pita running Claude instance za prijedlog (nice-to-have, integriše se sa multi-agent switchingom iz 0031)

**Push/Pull:**
- "Push" button + branch selector dropdown
- "Pull" button
- Branch info: trenutna branch + remote tracking (`origin/main ↑2`)

## Implementacija

- Sve git operacije: shell-out na `git` binary (ne libgit2)
- Shell-out via terminal PTY channel, rezultati parsirani i prikazani vizualno

## Acceptance criteria

Git repo, promijeni fajl, otvori git panel, stage, commit message, commit, push —
sve bez direktnog terminala. Diff se prikazuje ispravno za .dart fajl.
