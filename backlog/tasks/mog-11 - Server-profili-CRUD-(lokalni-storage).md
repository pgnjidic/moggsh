---
id: MOG-11
title: Server profili CRUD (lokalni storage)
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

Upravljanje saved server konfiguracijama — Home screen je ovo.

## Data model

```dart
class ServerProfile {
  String id;              // UUID
  String name;            // display ime
  String host;
  int port;               // default 22
  AuthType authType;      // password | key | keyWithPassphrase
  String username;
  String? passwordEncrypted;
  String? keyId;          // ref na SSH key
  String? startupScript;  // npr. "tmux attach || tmux new"
  DateTime? lastConnected;
  bool? isOnline;         // cached status
  String? color;          // visual tag
  List<String> tags;
}
```

## Screens

**Home screen — host lista:**
- Sekcije: LOCAL (amber header) i SSH SERVERS (blue header)
- Sortirano po `lastConnected`
- Host kartica po design sistemu (glow dot, tool badges)
- Long-press → edit/delete/duplicate

**Add/Edit server screen:**
- Forma sa validacijom (required: host, username, authType)
- "Test Connection" button u edit formi

**Quick-connect:**
- Tap na karticu → odmah konekcija (connection indicator u tabu)

## Import/Export

- Export profila kao encrypted JSON (backup / novi telefon)
- Import sa JSON fajla

## Acceptance criteria

Dodaj server → pojavi se u listi → tap → konekcija.
Edit mijenja podatke. Delete uklanja. Export/import round-trip radi.
