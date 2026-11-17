# MooriShell Architecture — Initial Overview

**Status:** Exploratory. This document records the intended boundaries, not a completed implementation.

## Objective

MooriShell is a Windows-native integration and configuration project. It aims to assemble a cohesive desktop workflow from existing Windows applications and open-source tools.

It is not intended to replace the Windows operating system, nor to claim ownership of the upstream tools it configures.

## Conceptual layers

| Layer | Responsibility | Tool | Integration tier |
|---|---|---|---|
| Shell experience | Entry points and desktop interaction | Shelled | Core |
| Window management | Tiling, layouts and workspaces | Komorebi | Core |
| Status and system information | Desktop status bar | YASB | Core |
| Terminal | Terminal interface and profiles | WezTerm | Core |
| Linux development environment | Linux userland and developer workflows | WSL2 | Optional |
| Containers | Containerized development workloads | Docker | Optional |
| Software provisioning | Installing and updating Windows tools | Scoop / WinGet / Chocolatey | Experimental (under evaluation) |
| Runtime provisioning | Selecting language/runtime versions | mise | Experimental (under evaluation) |
| Developer toolchains | Language and compiler toolchains | Bun, Node.js, Rust, Go, C/C++ | Experimental (under evaluation) |

The exact integration contracts and ownership boundaries are documented in `docs/architecture/adr/`. See the [roadmap](roadmap.md) for the planned decision and implementation sequence.

## Repository-owned responsibilities

MooriShell should own:

- Its documentation and design identity.
- Configuration files and documented adaptations.
- Setup, validation and maintenance scripts.
- Dependency declarations and compatibility guidance.
- Tests or checks for MooriShell-owned automation.

Upstream projects should own their respective executables, source code, release cycles and licenses unless MooriShell explicitly maintains a separately licensed fork.

Original MooriShell materials are licensed under the MIT License. That license does not replace or modify the licenses of upstream applications, dependencies, assets, or binaries.

## Configuration strategy

MooriShell keeps configurations modular and attributable to the application they configure. Shared defaults are documented; machine-specific values and secrets are not committed.

Configuration ownership:

- **MooriShell-owned configuration** lives in `configs/` and is versioned in the repository.
- **Application defaults** live in the upstream application's install directory and are owned by the upstream project.
- **User customizations** and **machine-specific overrides** live outside the repository and are never committed.
- **Secrets** (tokens, keys, passwords, credentials) are never stored in the repository.

Configuration rules:

- Where each application's configuration lives: documented in `configs/`; MooriShell-owned files are separate from upstream defaults.
- Which tool is authoritative when two tools overlap: the application that owns the functionality owns its configuration; MooriShell does not override upstream defaults.
- How configuration is backed up and restored: users back up machine-specific overrides and secrets separately; MooriShell-owned configuration is versioned in the repository.
- How updates are applied and validated: users apply configuration changes manually; MooriShell does not automate updates in M1.
- How users can disable or remove an integration: MooriShell removes only its own configuration files; upstream applications are not removed.

## Package-manager policy

Scoop, WinGet and Chocolatey are under evaluation. **No package manager is selected in M1.** MooriShell does not install or manage packages automatically.

Avoid managing the same application through multiple package managers unless there is a documented reason. A future tool manifest should identify the chosen source and update mechanism for each dependency.

## Reliability and safety

Setup automation should be incremental, inspectable and reversible where practical. It should not silently overwrite user configuration or remove existing applications.

## Open architecture decisions

### Decided (M1)

- **Scope**: Shelled, Komorebi, YASB, WezTerm are core; WSL2 and Docker are optional; package managers and toolchains are experimental; Winlogon shell replacement is out of scope (ADR-003).
- **Windows baseline**: Windows 11 64-bit; Shelled runs in dev mode alongside Explorer (ADR-002).
- **Ownership boundaries**: MooriShell owns configuration files; upstream tools own their executables and release cycles (ADR-004).
- **Package-manager policy**: No package manager selected in M1; no automatic package management (ADR-005).
- **Configuration ownership**: MooriShell owns `configs/`; user customizations and secrets live outside the repository (ADR-006).

### Still open

- How Komorebi and YASB are started, supervised and restarted (M2 provisioning).
- The relationship between Windows, WSL2 and Docker workspaces (M5).
- Package-manager selection and tool manifest (M2 provisioning).

Update this document as implementation decisions are validated.

Update this document as implementation decisions are validated.
