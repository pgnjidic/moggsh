---
id: MOG-17
title: Design system implementacija (cyberpunk aesthetic)
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

Cijeli mogsh design system kao Flutter theme + custom widget library.
Cyberpunk terminal aesthetic: duboki crni prostor, neon cyan/teal akcenti, glow efekti.

## ThemeData i Color System

Implementirati kao `ThemeData` + custom `MogshColors` extension:

```dart
// Primjeri ključnih boja:
bgVoid:        Color(0xFF0A0A14)   // najdublji sloj
bgBase:        Color(0xFF0A1A1A)   // terminal bg
neon:          Color(0xFF4AE8C0)   // primary accent
neonBright:    Color(0xFF00FFAA)   // glow, status dots
blue:          Color(0xFF00AAFF)   // SSH, AI output
amber:         Color(0xFFFFAA00)   // warnings, approval
```

Kompletna paleta iz design spec-a (sve `--bg-*`, `--neon-*`, `--blue-*`, `--amber-*`, `--text-*`).

## Spacing i Radius

```dart
class MogshSpacing { static const xxs = 2.0; xs = 4.0; sm = 6.0; md = 8.0; lg = 10.0; xl = 12.0; xxl = 16.0; }
class MogshRadius  { static const xs = 2.0; sm = 4.0; md = 6.0; lg = 10.0; xl = 12.0; }
```

## Custom Widgets (sve po spec-u)

| Widget | Opis |
|--------|------|
| `GlowDot` | Status dot sa animiranim pulse efektom |
| `NeonBorder` | Container sa glow border |
| `HostCard` | Kartica servera, sva stanja |
| `SectionHeader` | "LOCAL" / "SSH SERVERS" header sa glow |
| `ToolBadge` | "CC", "Aider" pill |
| `MogshButton` | primary/secondary/danger + glow |
| `ApprovalBanner` | amber banner sa Y/N |
| `ProjectHeaderBar` | top bar sa project imenom |
| `TmuxStatusBar` | tmux status prikaz |
| `KeyButton` | keyboard shortcut button |

## Glow animacije

- `GlowPulse`: opacity 0.8→1.0, 2s ease-in-out loop
- `AgentThinking`: amber pulse
- `VoiceActive`: expanding ring od mic buttona
- Tab switch: crossfade 150ms

## Pravila iz spec-a (enforced)

- Glow NIKAD na statičnim elementima
- Pure black (#000000) zabranjen — uvijek `#0a0a14`
- JetBrains Mono svuda (UI + terminal)
- Nema stock Material komponenti vidljivih u UI

## Deliverable

Widget catalog ekran (debug only) koji prikazuje sve komponente u svim stanjima.

## Acceptance criteria

Vizualno identično design spec-u. Widget catalog prikazuje sve komponente.
Nema stock Material widgeta vidljivih u produkcijskom UI-u.
