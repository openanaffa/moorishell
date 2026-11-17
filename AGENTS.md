# MooriShell — Coding Agent Handoff

This file is the working handoff for coding agents operating in this repository. Read it before making changes.

## Project identity

**MooriShell** — “A Moorish take on the Windows desktop.”

Repository: https://github.com/openanaffa/moorishell

MooriShell is an experimental, Windows-native desktop workspace inspired by Linux tiling workflows and Moroccan design. It integrates existing applications through MooriShell-owned configuration, automation, documentation, and tests.

It is not a replacement operating system, a new Windows shell implementation, or a reimplementation of upstream tools.

**Current maturity:** early experiment. There is no stable installer or supported distribution yet.

## Source of truth

Read these before implementation:

1. [README.md](README.md) — project purpose, status, principles.
2. [Roadmap](docs/roadmap.md) — milestones, tasks, exit criteria, execution order.
3. [Architecture overview](docs/architecture/overview.md) — current conceptual boundaries and unresolved decisions.
4. [Contributing guide](CONTRIBUTING.md) — contribution and safety requirements.
5. [LICENSE](LICENSE) — MIT license for original MooriShell materials.

The roadmap is tracked through GitHub Issues [#1–#8](https://github.com/openanaffa/moorishell/issues). Keep issue checklists and roadmap status synchronized when work is completed.

## Current project context

The user has reported experimenting with this Windows-oriented stack:

- Shelled — shell experience.
- Komorebi — tiling and workspaces.
- YASB — status bar.
- WezTerm — terminal.
- WSL2 and Docker — Linux and container environments.
- Scoop, WinGet, Chocolatey — package managers under evaluation.
- mise — runtime/version management under evaluation.
- Bun, Node.js, Rust, Go, C/C++, and other developer toolchains.
- Zed, VS Code, and GitHub Desktop as potential supporting applications.

Treat this as reported environment context, not a verified compatibility matrix. Confirm installed versions and actual behavior before making compatibility claims.

## Product principles

- Windows-native first; Linux-inspired workflow.
- Integrate upstream tools rather than replacing or duplicating them.
- Keep core desktop functionality separate from optional integrations.
- Prefer reproducible, inspectable, idempotent configuration and setup.
- Preserve existing user configuration; back up before modifying it.
- Make setup, update, restore, and uninstall behavior explicit.
- Do not claim support for untested Windows builds, hardware, or tool versions.
- Do not commit secrets, private keys, credentials, personal paths, or machine-specific state.
- Do not redistribute upstream binaries, code, or assets without checking their licenses and terms.

## Design direction

Use a restrained Moroccan visual identity rather than a generic themed Windows skin:

- Dark, translucent surfaces and compact panels.
- Keyboard-driven navigation and tiling.
- Atlas/night neutrals with Morocco red, desert sand, Atlantic blue, and zellige green accents.
- Geometric patterns and architectural forms as subtle design elements.

Do not invent or proliferate design tokens before recording them in the design system.

## Repository ownership and licensing

MooriShell owns its documentation, original branding, configurations, scripts, manifests, and tests.

Upstream applications retain ownership of their code, executables, assets, release cycles, and licenses. The repository's MIT license applies to original MooriShell materials and does not relicense upstream dependencies or third-party assets.

## Working rules for the coding agent

1. **Start from the roadmap.** Work on the currently selected GitHub milestone issue. Do not independently reorder or expand scope.
2. **One focused change at a time.** Avoid broad refactors and unrelated cleanup.
3. **Inspect before editing.** Check existing files, upstream documentation, versions, and current repository conventions.
4. **No speculative implementation.** If a decision is unresolved in the architecture, propose a concise decision with trade-offs before encoding it.
5. **Prefer PowerShell for Windows host automation** unless a specific technical reason supports another language.
6. **Make scripts safe by default.** Include prerequisite checks, clear logs/errors, explicit destructive actions, and recovery guidance. Never silently overwrite or uninstall user software.
7. **Keep configuration modular.** Separate shared defaults from machine-specific overrides and secrets.
8. **Validate every change.** Run relevant syntax checks/tests and report exact commands and results. If a test cannot be run, state why.
9. **Update documentation.** Keep README, architecture, roadmap, and issue checklists accurate as implementation changes.
10. **Do not fabricate completion.** Distinguish implemented, tested, experimental, and planned behavior.
11. **Keep user communication concise.** Report what changed, files affected, validation results, blockers, and the next decision/action. Avoid long unsolicited plans.

## Current execution priority

**Start with M1 — Define product scope and architecture.**

Tracking issue: https://github.com/openanaffa/moorishell/issues/1

Resolve these before building the provisioning workflow:

- Supported Windows baseline and minimum assumptions.
- Core, optional, experimental, and out-of-scope integrations.
- Ownership boundaries and startup/lifecycle contracts for desktop components.
- Package-manager ownership policy for WinGet, Scoop, and Chocolatey.
- Configuration ownership, machine-specific overrides, secrets, backup, restore, and uninstall behavior.

Record durable decisions in short Architecture Decision Records under `docs/architecture/adr/` (create the directory when the first ADR is approved) and update `docs/architecture/overview.md`.

Do not implement M2 provisioning until the decisions that affect its design are settled or explicitly marked as deferred.

## Expected handoff after each task

Provide:

- Summary of the change.
- Files created or modified.
- Tests/checks run and their results.
- Related GitHub issue and checkbox updates.
- Remaining risks or unresolved decisions.

Do not push, merge, publish releases, or make destructive machine-level changes unless the user explicitly authorizes that action.
