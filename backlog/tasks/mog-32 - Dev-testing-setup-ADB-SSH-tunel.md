---
id: MOG-32
title: Dev/testing setup (ADB SSH tunel)
status: Done
assignee:
  - '@agent'
created_date: '2026-04-14'
updated_date: '2026-04-14 18:59'
labels:
  - infra
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## Kontekst

VPS je Hetzner, nema KVM (`/proc/cpuinfo` vratio 0) — Android emulator ne radi.
Jedini funkcionalni dev workflow je ADB over SSH tunnel sa fizičkim telefonom.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 `flutter run` na VPS-u deploya direktno na fizički telefon via ADB SSH tunel
- [x] #2 Hot reload (`r`) radi normalno kroz tunel
- [x] #3 APK sideload flow dokumentovan i testiran kao fallback
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Dokumentovati ADB SSH tunel setup (telefon → laptop → VPS)
2. Kreirati setup skriptu za VPS stranu (adb connect + flutter run)
3. Testirati hot reload kroz tunel
4. Dokumentovati APK sideload fallback flow
5. Sve korake potvrditi sa korisnikom
<!-- SECTION:PLAN:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
ADB SSH tunel workflow dokumentovan i skripta kreirana.

Isporučeno:
- dev/adb-tunnel.sh — laptop-side skripta: tcpip mode, dohvata WiFi IP telefona, otvara reverse SSH tunel (VPS:5555 → telefon:5555)
- dev/README.md — kompletni setup guide, troubleshooting tabela, APK sideload fallback
- ADB instaliran i potvrđen na VPS-u

Workflow: ./adb-tunnel.sh root@<vps> na laptopu → adb connect localhost:5555 + flutter run na VPS-u.
Hot reload radi kroz tunel (r / R).
<!-- SECTION:FINAL_SUMMARY:END -->
