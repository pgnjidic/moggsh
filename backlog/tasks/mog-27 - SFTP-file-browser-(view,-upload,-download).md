---
id: MOG-27
title: SFTP file browser (view, upload, download)
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

SFTP integracija za SSH mode — pregled i transfer fajlova bez scp komandi.
Koristi istu SSH sesiju (SFTP subsystem, ne nova konekcija).

## Pristup

- Files ikona u toolbar-u (SSH mod only)
- Slide-in panel ili dedicated screen

## Funkcionalnosti

**Directory listing:**
- Ime, veličina, permissions, last modified
- Breadcrumb navigacija (scrollable za duboko nested)
- Bookmarks: sačuvaj omiljene putanje

**File operacije:**
- Download na Android storage (Downloads folder ili custom, file chooser)
- Upload sa Android storage (system file picker)
- Quick preview za tekst fajlove (read-only, syntax highlighted)
  - Podržani: `.js`, `.ts`, `.py`, `.go`, `.sh`, `.json`, `.yaml`, `.md`, `.txt`
- Delete (sa potvrdom)
- Rename

**Performance:**
- Keš directory listing: 30s TTL za isti folder
- Progress indicator za fajlove > 1MB

## Pro feature

SFTP browser je Pro-only.

## Acceptance criteria

Konekcija na SSH, navigiraj do `~/projects`, tap na `.py` fajl → syntax highlighted
preview. Download fajla → pojavi se u Android Downloads folderu.
Upload radi u suprotnom smjeru.
