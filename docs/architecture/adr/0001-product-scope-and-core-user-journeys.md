# ADR-001: Product scope and core user journeys

**Status:** Accepted  
**Date:** 2026-11-17  
**Deciders:** MooriShell project maintainer

## Context
MooriShell is an experimental Windows-native workspace assembled from upstream applications. M1 defines its product boundary and the workflows later provisioning and desktop integration must support.

## Decision
MooriShell integrates existing Windows applications through its own configuration, automation, and documentation. It does not replace Windows, reimplement upstream tools, or claim ownership of their binaries or source.

### Primary user journeys
1. **Enter a coherent desktop:** Start Shelled in development mode alongside Explorer, with Komorebi managing tiling/workspaces, YASB providing status, and WezTerm available as the terminal.
2. **Navigate by keyboard:** Launch/focus applications, move between windows, and switch workspaces using documented shortcuts.
3. **Configure the workspace:** Change MooriShell defaults and application settings without editing upstream binaries or losing user customizations.
4. **Build a developer workspace:** Reproduce selected runtimes, compilers, Git/GitHub tools, and supporting applications through an explicit developer profile (M4); Linux/container environments remain opt-in (M5).
5. **Maintain or remove the setup:** Apply updates safely, back up affected configuration, restore prior state, and remove only MooriShell-managed changes.

### Scope boundaries
- Core desktop: Shelled (development-mode host), Komorebi, YASB, and WezTerm.
- Optional integrations: PowerToys, WSL2, Docker, and supporting productivity applications.
- Developer tooling is a separate profile, not a prerequisite for the core desktop.
- Replacing Explorer through Winlogon, bundling upstream binaries, and forking upstream projects are out of scope unless a later ADR explicitly changes this.

## Consequences
- The core desktop can be adopted independently of developer tooling and Linux/container workflows.
- Shelled remains in development mode; no Winlogon shell registration or automatic recovery is promised in M1.
- M2/M3 must implement and validate provisioning and lifecycle behavior before the workflow can be described as reproducible.

## Alternatives considered
- **Replace Explorer through Winlogon:** Rejected for the experimental stage because it increases recovery risk and may break Explorer-dependent integrations.
- **Build a new window manager or terminal:** Rejected because the project is integration-first.

## Related
ADR-003, ADR-004, ADR-005, ADR-006; Roadmap M1: https://github.com/openanaffa/moorishell/issues/1
