---
id: MOG-14
title: Mosh podrška za nestabilan internet
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

Mosh (Mobile Shell) je UDP-based protokol koji preživljava IP promjene, kratke
pauze interneta i sleep/wake cikluse. Idealan za mobilni razvoj.

## Implementacija opcije

Istraži redoslijedom:
1. Postoji li Flutter/Dart mosh library? (vjerovatno ne)
2. **Option A**: Bundlati precompiled `mosh-client` ARM64 binary u app assets
3. **Option B**: SSH tunel kao posrednik za mosh

Trenutna preporuka: Option A.

## Konekcija flow

1. SSH connect normalno
2. Pokreni `mosh-server` na remote, dobij UDP port + key
3. Prekini SSH
4. Konekcija via mosh protokol na dobiveni port

## UI

- Per server profilu: checkbox "Use Mosh (requires mosh-server on remote)"
- Mosh server detection: `which mosh-server` na connect, disable checkbox ako nema
- "Connected via Mosh" badge u tab-u
- Seamless reconnect na network promjenu (WiFi ↔ LTE)
- Fallback: ako mosh ne radi → "Switch to SSH" opcija

## Acceptance criteria

Konekcija via Mosh, simuliraj airplane mode 10 sekundi → reconnect automatski
bez gubitka sesije. "Connected via Mosh" badge vidljiv u tabu.
