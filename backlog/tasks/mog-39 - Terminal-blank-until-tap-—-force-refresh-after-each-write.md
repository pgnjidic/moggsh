---
id: MOG-39
title: Terminal blank until tap — force refresh after each write
status: Done
assignee:
  - '@agent'
created_date: '2026-04-19 08:47'
updated_date: '2026-04-19 08:48'
labels:
  - terminal
  - ux
  - android
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
After SSH connects, terminal stays blank (only cursor visible) until user taps screen. Root cause: xterm.js renders via requestAnimationFrame which Android WebView throttles when unfocused, so term.write(data) fills the internal buffer but the screen never repaints. Fix: use term.write(data, callback) — the callback fires synchronously after the parser processes the chunk, force term.refresh() there. One-line change in termWrite inside index.html.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Terminal shows MOTD and prompt immediately after connecting, without requiring a tap
- [x] #2 No regression: terminal still renders correctly during active typing
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Fixed blank terminal on connect by forcing term.refresh() in the term.write() callback. Android WebView throttles requestAnimationFrame when the view lacks focus, so xterm's internal buffer was populated but never painted. The write callback fires synchronously after the parser processes each chunk, guaranteeing a repaint. One-line change in assets/terminal/index.html.
<!-- SECTION:FINAL_SUMMARY:END -->
