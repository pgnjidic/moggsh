---
id: MOG-21
title: Performance optimization (terminal rendering)
status: To Do
assignee: []
created_date: '2026-04-14'
updated_date: '2026-04-14'
labels:
  - s5
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Terminal mora biti fluidan. Ovo je make-or-break za app — jedino gdje možemo
izgubiti 5-star review odmah.
<!-- SECTION:DESCRIPTION:END -->
## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Scroll kroz 500 linija AI outputa = 60fps na Snapdragon 665 / 4GB RAM
- [ ] #2 App startup do usable terminal < 2 sekunde
- [ ] #3 APK download size < 30MB
- [ ] #4 1000 linija scrollback bez lag-a ili OOM crash-a
<!-- AC:END -->


## Benchmark ciljevi

| Metrika | Cilj |
|---------|------|
| 200 linija AI outputa scroll | 60fps |
| 1000 linija scrollback | bez lag-a, Snapdragon 665 4GB RAM |
| App startup do usable terminal | < 2 sekunde |
| APK download size | < 30MB |

## Optimizacije za implementirati

**Terminal rendering:**
- Flutter DevTools profiler na terminal scroll — baseline mjerenje
- xterm/flutter_pty: virtualizovani render (samo vidljive linije)
- Ako xterm lagguje: native Android `TextureView` custom terminal renderer
- Batch ANSI processing: ne rerenderuj svaki bajt, batch u 16ms chunks
- `Isolate` za ANSI parsing (off main thread)

**Memory:**
- Scrollback buffer cap: 10.000 linija default, starije se odbacuju
- Per-tab memory limit: ~50MB scrollback

**APK veličina:**
- `flutter build appbundle --release --obfuscate`
- proot filesystem: komprimiran, lazy extract (ne sve odjednom na prvom pokretanju)
- Tree-shake unused assets

**Battery:**
- Foreground service samo kad terminal aktivan
- Wake lock samo dok čeka output
- Background: reducirati polling na 0 (event-driven, ne polling)

## Deliverables

- Profiler screenshot koji pokazuje 60fps scroll kroz 500 linija
- APK size report: < 30MB
- Startup trace: < 2s
