# MooriShell Architecture — Initial Overview

**Status:** Exploratory. This document records the intended boundaries, not a completed implementation.

## Objective

MooriShell is a Windows-native integration and configuration project. It aims to assemble a cohesive desktop workflow from existing Windows applications and open-source tools.

It is not intended to replace the Windows operating system, nor to claim ownership of the upstream tools it configures.

## Conceptual layers

| Layer | Responsibility | Current direction |
|---|---|---|
| Shell experience | Entry points and desktop interaction | Shelled |
| Window management | Tiling, layouts and workspaces | Komorebi |
| Status and system information | Desktop status bar | YASB |
| Terminal | Terminal interface and profiles | WezTerm |
| Linux development environment | Linux userland and developer workflows | WSL2 |
| Containers | Containerized development workloads | Docker |
| Software provisioning | Installing and updating Windows tools | Scoop, WinGet, Chocolatey under evaluation |
| Runtime provisioning | Selecting language/runtime versions | mise under evaluation |
| Developer toolchains | Language and compiler toolchains | Bun, Node.js, Rust, Go, C/C++ |

The exact integration contracts and ownership boundaries remain to be designed.

## Repository-owned responsibilities

MooriShell should own:

- Its documentation and design identity.
- Configuration files and documented adaptations.
- Setup, validation and maintenance scripts.
- Dependency declarations and compatibility guidance.
- Tests or checks for MooriShell-owned automation.

Upstream projects should own their respective executables, source code, release cycles and licenses unless MooriShell explicitly maintains a separately licensed fork.

## Configuration strategy

The intended approach is to keep configurations modular and attributable to the application they configure. Shared defaults should be documented; machine-specific values and secrets should not be committed.

Before adding automation, define:

- Where each application's configuration lives.
- Which tool is authoritative when two tools overlap.
- How configuration is backed up and restored.
- How updates are applied and validated.
- How users can disable or remove an integration.

## Package-manager policy

Scoop, WinGet and Chocolatey are being evaluated. No final ownership policy has been selected.

Avoid managing the same application through multiple package managers unless there is a documented reason. A future tool manifest should identify the chosen source and update mechanism for each dependency.

## Reliability and safety

Setup automation should be incremental, inspectable and reversible where practical. It should not silently overwrite user configuration or remove existing applications.

## Open architecture decisions

- Define the boundary between Shelled and the other desktop components.
- Decide how Komorebi and YASB are started, supervised and restarted.
- Define configuration backup and restore behavior.
- Select the package-manager ownership policy.
- Define the relationship between Windows, WSL2 and Docker workspaces.
- Select a license for original MooriShell materials.

Update this document as implementation decisions are validated.
