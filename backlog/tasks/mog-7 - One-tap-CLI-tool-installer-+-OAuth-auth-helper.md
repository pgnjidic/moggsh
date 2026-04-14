---
id: MOG-7
title: One-tap CLI tool installer + OAuth auth helper
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s2
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ekran za instalaciju popularnih vibe coding alata jednim tapom + OAuth flow za autentifikaciju.
Ovo je najvažniji onboarding moment — korisnik mora doći do `claude` radnog stanja
bez ikakve terminalne gimnastike.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Tap 'Install Claude Code' → instalirano, zeleni badge sa verzijom
- [ ] #2 OAuth flow otvara browser, token se vrati via deep link i sačuva
- [ ] #3 `claude` radi u terminalu s autorizacijom
- [ ] #4 Error state (crveni Failed + Retry) prikazuje se ako install pukne
- [ ] #5 Cijeli flow (install + auth) < 3 minute
<!-- AC:END -->


## Alati

| Tool | Install komanda | Auth |
|------|----------------|------|
| Claude Code | `npm install -g @anthropic-ai/claude-code` | Anthropic OAuth |
| Aider | `pip install aider-chat` | OpenAI/Anthropic API key |
| Codex CLI | `npm install -g @openai/codex` | OpenAI OAuth |
| OpenCode | `npm install -g opencode` | Anthropic/OpenAI |
| Amp | `npm install -g @anthropic-ai/amp` | Anthropic OAuth |

## UI komponente

- Tool kartica: logo + ime + kratki opis + "Install" button ili "Installed ✓" badge
- Install tap → terminal panel slide-up prikazuje npm/pip output (real-time)
- Success: zeleni "Installed" badge + verzija
- Error: crveni "Failed" + "Retry" + view full error
- "Update available" indicator (`npm outdated` provjera)

## Auth Helper

- Detektuj koji tool treba koji API key
- "Authenticate Claude Code" → otvori Anthropic OAuth u system browseru
- Token se vrati via deep link: `app.mogsh.terminal://auth/callback`
- Token sačuvaj encrypted u `flutter_secure_storage`
- Isto za OpenAI (Codex), Aider (direktni key unos)

## Blokiran na

- 0006 (Node.js i Python moraju biti instalirani)
