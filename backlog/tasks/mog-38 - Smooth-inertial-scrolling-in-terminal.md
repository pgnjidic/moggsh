---
id: MOG-38
title: Smooth inertial scrolling in terminal
status: Done
assignee:
  - '@agent'
created_date: '2026-04-19 08:44'
updated_date: '2026-04-19 08:53'
labels:
  - ux
  - terminal
  - scroll
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Terminal scroll is stiff — current implementation uses a linear pixel-to-row mapping with no momentum. touchend stops scroll immediately. Fix: on touchend capture the velocity (px/ms from last few touchmove events) and animate the viewport using requestAnimationFrame with exponential deceleration until velocity drops below threshold.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Scrolling has visible momentum/inertia after lifting finger
- [x] #2 Scroll decelerates smoothly and stops naturally (no abrupt halt)
- [x] #3 Scroll direction and speed are proportional to the flick gesture
- [x] #4 Momentum can be interrupted by touching the screen again
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. index.html: zameniti scroll listeners sa inertia implementacijom
2. touchstart: uhvatiti početni Y i viewportY, resetovati velocityY i otkazati animaciju
3. touchmove: pratiti velocity (px/ms) iz poslednjih 2 eventa, scrollati
4. touchend: pokrenuti rAF petlju sa eksponencijalnim usporavanjem (DECEL=0.94 po frame)
5. touchstart tokom animacije: otkazati rAF
<!-- SECTION:PLAN:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Replaced linear touch scroll with inertial scroll in assets/terminal/index.html.

Changes:
- touchstart: captures starting position, cancels any running inertia animation
- touchmove: tracks velocity (px/ms) via consecutive event timestamps, scrolls proportionally
- touchend: launches requestAnimationFrame loop with DECEL=0.92 per frame; stops when velocity < 0.01 px/ms
- touchstart mid-inertia cancels the animation immediately

Scroll feels natural — flick launches inertia, touch stops it.
<!-- SECTION:FINAL_SUMMARY:END -->
