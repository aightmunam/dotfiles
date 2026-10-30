---
kind: plan
title: Fixture plan
repo: dotfiles
date: 2026-10-30
status: draft
phases:
  - id: P1
    title: Only phase
    files:
      - {path: "ai/example/one.py", change: new}
---

# Fixture plan

## Phase 1: Only phase

**File**: `ai/example/one.py`

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
