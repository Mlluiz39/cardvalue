<!-- Sync Impact Report
  Version change: 0.0.0 → 1.0.0
  Modified principles: (all) placeholders → concrete Clean Code principles
    - [PRINCIPLE_1_NAME] → I. Simplicity First (KISS/YAGNI)
    - [PRINCIPLE_2_NAME] → II. Meaningful Names
    - [PRINCIPLE_3_NAME] → III. Single Responsibility
    - [PRINCIPLE_4_NAME] → IV. Self-Documenting Code
    - [PRINCIPLE_5_NAME] → V. Manual Verification
  Added sections:
    - Constraints & Code Standards
    - Development Workflow
  Removed sections: (none)
  Templates requiring updates: ✅ .specify/templates/plan-template.md
  Follow-up TODOs: (none)
-->

# cardvalue Constitution

## Core Principles

### I. Simplicity First (KISS/YAGNI)
Start with the simplest solution that works. No premature abstractions,
design patterns, or dependencies. Complexity MUST be justified by proven
need, not anticipated future requirements. A small codebase is a feature.

### II. Meaningful Names
Every name MUST reveal intent. Choose names that answer: why it exists,
what it does, and how it is used. Avoid abbreviations, acronyms, and
single-letter names (except loop counters). Rename whenever a better
name emerges.

### III. Single Responsibility
Each function, module, and file MUST have exactly one clear responsibility.
Functions MUST fit on a screen (~20 lines max). Files MUST stay under
300 lines. If a component is doing more than one thing, split it.

### IV. Self-Documenting Code
Code MUST be readable without comments. Express intent through naming,
structure, and small abstractions. Comments explain WHY (rationale,
trade-offs), never WHAT (the code already says that). Update comments
when changing code — incorrect comments are worse than none.

### V. Manual Verification
No automated tests. Correctness is verified through manual testing,
interactive exploration, and visual inspection. Every change MUST be
exercised manually before commit. The small codebase makes thorough
manual verification practical and fast.

## Constraints & Code Standards

- **Formatting**: Use consistent indentation and style. No linter required
  — enforce discipline through code review.
- **Dependencies**: Minimize external dependencies. Only use what is
  strictly necessary. Prefer standard library solutions.
- **File size**: Maximum 300 lines per source file.
- **Function size**: Maximum ~20 lines per function.
- **No dead code**: Remove commented-out code and unused imports
  immediately.

## Development Workflow

1. Understand the problem fully before writing code.
2. Write the simplest possible solution.
3. Manually verify every code path.
4. Review for naming, duplication, and clarity.
5. Commit small, coherent changes with descriptive messages.

## Governance

This constitution defines the non-negotiable principles of the project.
Amendments require:
- A documented rationale for the change.
- Review and approval by at least one other contributor.
- Version bump per semantic versioning rules.

**Version**: 1.0.0 | **Ratified**: 2026-05-18 | **Last Amended**: 2026-05-18
