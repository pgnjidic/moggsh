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

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Upravljanje saved server konfiguracijama — Home screen je ovo.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Dodaj server → pojavi se u listi → tap → konekcija uspostavljena
- [ ] #2 Edit mijenja podatke, Delete uklanja profil
- [ ] #3 Export/import round-trip radi (JSON backup)
- [ ] #4 Startup script se izvršava automatski na connect
- [ ] #5 Quick-connect < 3s od tapa do otvorene sesije
<!-- AC:END -->


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
