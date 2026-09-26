---
name: explain_code
description: Deep explanation of code with diagrams and thorough analysis
model: opus
---

# Explain Code

You are tasked with providing deep explanations of code. This command analyzes code structure, behavior, and provides clear explanations with ASCII diagrams.

## Initial Response

When invoked with a parameter (file path or function name):
- Immediately begin analysis of the specified code

When invoked without parameters:
```
I'll help you understand code in depth.

Please provide:
- A file path: `hld/internal/session/manager.go`
- A function/class name: `SessionManager.CreateSession`
- Or paste a code snippet

Optionally specify what aspects interest you:
- How it works (execution flow)
- Why it's designed this way (design decisions)
- How it integrates (dependencies and callers)
- Data flow (inputs, transformations, outputs)
- Error handling

I'll provide a thorough explanation with diagrams.
```

## Process Steps

### Step 1: Identify Code Scope

1. **Parse input**:
   - File path → Read the entire file
   - Function/class name → Search codebase and read relevant file(s)
   - Code snippet → Analyze as provided

2. **Read the code** into context using the Read tool

### Step 2: Deep Analysis

Spawn **3 parallel Task agents** using `codebase-analyzer`:

#### Agent 1: Structure Analysis
```
Analyze the structure of [code reference]:

1. List all functions/methods/classes and their purposes
2. Identify public vs private interfaces
3. Map dependencies and imports
4. Note configuration and constants
5. Identify the main entry points

Return a structural breakdown with clear hierarchy.
```

#### Agent 2: Data Flow Analysis
```
Trace data flow through [code reference]:

1. Identify all input sources (parameters, config, external data)
2. Map transformations applied to data
3. Identify output destinations (return values, side effects, storage)
4. Note any state mutations
5. Identify error paths and how errors propagate

Return a clear description of how data moves through the code.
```

#### Agent 3: Integration Analysis
```
Analyze how [code reference] integrates with the rest of the codebase:

1. Find all callers of this code (who uses it?)
2. Find all callees (what does it depend on?)
3. Identify shared state or resources
4. Note any event/message patterns
5. Identify the broader system context

Return integration points with file:line references.
```

### Step 3: Generate Explanation

Synthesize findings into a clear explanation:

#### 3.1 Overview Section
- What the code does (1-2 sentences)
- Why it exists (the problem it solves)
- When it runs (trigger conditions)

#### 3.2 Architecture Diagram (ASCII)
Create a visual representation:

```
┌─────────────────────────────────────────────────────────┐
│                      [Main Component]                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   ┌──────────┐     ┌──────────┐     ┌──────────┐       │
│   │  Input   │────▶│ Process  │────▶│  Output  │       │
│   └──────────┘     └────┬─────┘     └──────────┘       │
│                         │                               │
│                    ┌────▼─────┐                         │
│                    │ Storage  │                         │
│                    └──────────┘                         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

#### 3.3 Step-by-Step Walkthrough
Walk through the code block by block:

```
### 1. Initialization (lines 10-25)
[Explain what happens and why]

### 2. Main Logic (lines 26-50)
[Explain the core algorithm/process]

### 3. Cleanup/Return (lines 51-60)
[Explain how it concludes]
```

#### 3.4 Data Flow Diagram
```
Input ──▶ Validate ──▶ Transform ──▶ Store ──▶ Output
              │
              ▼
          [Error] ──▶ Log ──▶ Return Error
```

#### 3.5 Key Design Decisions
Explain non-obvious choices:
- "Why use a map here instead of a slice?"
- "Why is this async vs sync?"
- "Why this error handling approach?"

#### 3.6 Common Questions
Anticipate and answer:
- "What happens if X fails?"
- "Why not do Y instead?"
- "How does this handle edge case Z?"

### Step 4: Present Explanation

Format the explanation clearly:

```markdown
# Understanding: [Code Name]

## Overview

[High-level explanation of what this code does and why it exists]

**Location**: `path/to/file.go:10-150`
**Type**: [Function/Class/Module/Service]
**Responsibility**: [Single sentence describing its job]

## Architecture

```
[ASCII diagram showing component relationships]
```

## How It Works

### 1. [First Major Step]

**Lines**: 10-25
**Purpose**: [What this section accomplishes]

```go
// Key code snippet with comments
```

[Explanation of what's happening and why]

### 2. [Second Major Step]

**Lines**: 26-50
**Purpose**: [What this section accomplishes]

[Explanation continues...]

## Data Flow

```
[Data flow diagram]
```

**Inputs**:
- `param1` - [What it represents, where it comes from]
- `config.Setting` - [Configuration dependency]

**Outputs**:
- Return value - [What it represents]
- Side effects - [Any mutations or external changes]

## Integration

**Called by**:
- `package/caller.go:45` - [Context of usage]
- `other/file.go:123` - [Context of usage]

**Calls**:
- `dependency.Function()` - [Why it's needed]
- `database.Query()` - [Why it's needed]

**Related Code**:
- `similar/implementation.go` - [How it relates]

## Design Decisions

### Why [specific choice]?

[Explanation of the trade-off and reasoning]

### Why not [alternative]?

[Explanation of why the alternative wasn't chosen]

## Edge Cases & Error Handling

| Scenario | Handling | Location |
|----------|----------|----------|
| [Edge case 1] | [How it's handled] | line 35 |
| [Error condition] | [How it's handled] | line 42 |

## Questions You Might Have

**Q: What happens if the database is unavailable?**
A: [Answer with code reference]

**Q: Is this thread-safe?**
A: [Answer with explanation]

## Further Reading

- `related/code.go` - [Why it's relevant]
- [External doc/concept] - [Why it helps understand this code]
```

### Step 5: Offer Follow-up

```
Would you like me to:
- Explain any specific part in more detail?
- Show how this code is used in practice (trace a real call)?
- Compare this to alternative implementations?
- Trace what happens for a specific input scenario?
```

## Diagram Guidelines

Always use ASCII diagrams for:
- Component relationships
- Data flow
- State machines
- Sequence of operations

Keep diagrams:
- Simple and focused
- Using box-drawing characters: `┌ ┐ └ ┘ │ ─ ├ ┤ ┬ ┴ ┼ ▶ ▼`
- With clear labels
- Sized appropriately (not too wide for terminal)

## Important Notes

- Always read the actual code before explaining
- Use file:line references for all claims
- Explain the "why" not just the "what"
- Anticipate follow-up questions
- Use diagrams to illustrate complex flows
- Match explanation depth to code complexity
- Run analysis agents in parallel for efficiency
