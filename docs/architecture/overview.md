# MooriShell Architecture — Initial Overview

**Status:** Exploratory. This document records current decisions and implementation boundaries, not a completed implementation.

## Objective
MooriShell is a Windows-native integration and configuration project. It assembles a keyboard-driven desktop workflow from existing applications and open-source tools. It does not replace Windows or reimplement upstream applications.

## Conceptual layers
| Layer | Responsibility | Tool | Integration tier |
|---|---|---|---|
| Shell experience | Desktop entry point | Shelled (development mode) | Core |
| Window management | Tiling, layouts, workspaces | Komorebi | Core |
| Status and system information | Status bar | YASB | Core |
| Terminal | Terminal interface and profiles | WezTerm | Core |
| Windows utilities | Launcher and supporting utilities | PowerToys | Optional |
| Linux development environment | Linux userland | WSL2 | Optional |
| Containers | Containerized workloads | Docker | Optional |
| Developer toolchain | Runtimes, compilers, Git/GitHub tools | Developer profile | Optional |
| Productivity applications | Knowledge and editor integrations | Obsidian, Zed, VS Code, GitHub Desktop | Optional |

## Repository-owned responsibilities
MooriShell owns its original documentation, branding, configuration templates, dependency catalog, automation, and tests. Upstream projects retain ownership of their executables, source, assets, release cycles, and licenses. The repository MIT license applies only to original MooriShell materials.

## Configuration model
- Versioned defaults live in configs/<app>/.
- Deployed application files live at documented native application paths.
- User and machine-specific overrides, backups, logs, and provisioning state live outside the repository, under local application data or an application-specific location.
- Secrets remain in Windows Credential Manager, a DPAPI-backed store, or the application's secret store; never in the repository or plain-text MooriShell configuration.
- Updates and uninstall use a local state manifest and hash checks. Modified user files are preserved, not silently overwritten or deleted.

See ADR-006 for the full configuration lifecycle.

## Package-manager policy
MooriShell does not mandate one global package manager. Each managed package has exactly one authoritative source in the dependency manifest. Prefer Scoop for suitable user-scoped portable tools, WinGet for Windows-native applications/installers, and direct official releases when more appropriate. Chocolatey is an explicit exception, not a default. mise may own selected language runtimes. Never install the same package through multiple managers.

See ADR-005 for the manifest contract and source-selection rules.

## Reliability and safety
Provisioning must be explicit, inspectable, idempotent, and reversible. It must detect existing installations, preserve user configuration, and report unsupported/unresolved packages instead of treating placeholders as success.

## Current shell experience experiment
The Shelled experiment adds MooriShell branding, a WezTerm quick-launch button,
battery status, Komorebi-style workspace/window shortcuts, and a Quick Settings
flyout for launcher, terminal, power settings, and network settings. WezTerm is
invoked by command name through Shelled's allow-listed bridge rather than a
machine-specific release path. This work is on the Shelled feature branch
`feature/shell-quick-settings` at commit `23b9ba2`; it is not yet part of the
parent repository's pinned submodule commit. Development mode remains the only
validated use mode; Explorer/Winlogon is not modified.

## Decided architecture
- Product scope and primary journeys: ADR-001.
- Windows 11 x64 baseline policy; exact tested build/hardware floor pending evidence: ADR-002.
- Core, optional, and experimental integration tiers: ADR-003.
- Upstream and MooriShell ownership boundaries: ADR-004.
- One authoritative package source per managed dependency: ADR-005.
- Configuration ownership, backup, restore, and uninstall lifecycle: ADR-006.

## Deferred decisions
- Exact supported Windows build and minimum hardware: record after reproducible host validation.
- Per-package manager/source assignments and install detection: M2.
- Configuration destination mapping and state-manifest implementation: M2.
- Startup, supervision, restart, and recovery behavior for core desktop applications: M3.
- WSL2 distro baseline and container filesystem conventions: M5.

Update this overview when implementation evidence changes these decisions.
