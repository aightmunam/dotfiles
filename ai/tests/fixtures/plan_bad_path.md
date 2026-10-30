---
kind: plan
title: Fixture plan with defects
repo: dotfiles
date: 2026-10-30
status: draft
phases:
  - id: P1
    title: First phase
    files:
      - {path: "ai/example/bare.py", change: new}
      - {path: "ai/example/ghost.py", change: new}
      - {path: "ai/example/edited.py", change: edited}
  - id: P2
    title: Phase with no section
    files:
      - {path: "ai/example/two.py", change: new}
---

# Fixture plan with defects

## Phase 1: First phase

**File**: ai/example/bare.py
**File**: `ai/example/edited.py`

#### Automated verification
- [ ] `python3 -m unittest` passes.

## Before → After

### Before

```mermaid
flowchart LR
    A[Before] --> B[Work]
```

### After

```mermaid
flowchart LR
    A[After] --> B[Work]
```
