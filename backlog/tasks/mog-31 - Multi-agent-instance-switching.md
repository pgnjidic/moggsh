---
id: MOG-31
title: Multi-agent instance switching
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s4
dependencies: []
priority: medium
---

## Opis

Brzo skakanje između više Claude/agent instanci koje paralelno rade.
Svaka instanca je tab, ali trebamo poseban UX sloj koji razumije da su to
agenti, ne samo terminali — i koji može automatski prebacivati fokus.

## Problem

Korisnik vodi npr. 3 Claude Code instance (različiti projekti), plus Aider.
Svaka se povremeno zaustavi i čeka input. Trenutno moraš ručno gledati koji
tab je "stao" i prebaciti se tamo.

## Modovi prebacivanja

### 1. Manual switching (uvijek dostupno)
- Swipe između tabova ili tap na tab bar
- Keyboard shortcut (shortcut bar): `[◀]` `[▶]` za cycle kroz agente

### 2. Auto-switch na agent prompt (configurable)
- App detektuje kada agent u nekom tabu "stane" i čeka input
  (signal: prompt pattern `❯`, ili `(y/n)`, ili cursor idle > N sekundi)
- Automatski prebaci fokus na taj tab
- Animacija: tab flash + smooth crossfade
- Nakon što korisnik odgovori → opcije:
  - **"Return"**: automatski se vrati na prethodni tab
  - **"Stay"**: ostani na ovom tabu
  - **"Next waiting"**: idi na sljedeći tab koji čeka
  - Ovo je configurable po defaultu i po svakom tabu

### 3. Pinned tab (fiksni)
- Long-press na tab → "Pin this tab"
- Pinned tab nikad ne gubi fokus zbog auto-switch
- Use case: korisnik uvijek želi ostati na "main" agentu, a notifikacije
  mu samo kažu da drugi agent čeka
- Pinned tab ima posebnu ikonu (📌) i ne može biti auto-switched away

## Agent status overlay (nova komponenta)

Mini status bar na dnu ekrana (uvijek vidljiva, 24px visoka):

```
[CC: waiting ●]  [Aider: running ○]  [CC2: idle ○]
```

- Svaki agent: ime/tip + status dot + kratki status text
- Tap na stavku → skoči na taj tab
- "Waiting" tab pulsira (amber glow) — vizualni poziv pažnje

## Settings → Agent Switching

```
Auto-switch on agent prompt:  [Toggle: On/Off]
After responding, go to:      [Return to previous | Stay | Next waiting]
Pinned tab behavior:          [Never switch away | Notify only]
Switch animation:             [Crossfade | Instant | Slide]
```

## Notification integracija (veza sa 0023)

Kad je app u backgroundu:
- Notifikacija koja tab čeka
- Notifikacija ima "Quick Reply" action — inline y/n bez otvaranja app-a

## Acceptance criteria

3 aktivna Claude Code taba. Auto-switch uključen. Agent na tabu 2 čeka `(y/n)` →
app automatski skoči na tab 2 → tap Y → vrati se na tab 1 (Return mode).
Pinned tab: tab 1 je pinned → auto-switch NE prebacuje sa njega.
Status overlay prikazuje ispravne statuse sva 3 agenta u realnom vremenu.
