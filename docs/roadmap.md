# MooriShell Roadmap

**Status:** Active planning  
**Last updated:** 2026-11-17
**Delivery model:** Milestone-based; no calendar estimates until the scope and implementation pace are validated.

MooriShell is a Windows-native desktop workspace that combines existing applications, configuration, automation, and documentation. The roadmap prioritizes a dependable setup and daily workflow before optional visual and productivity features.

## Product direction

**A Moorish take on the Windows desktop.**

MooriShell should provide:
- A keyboard-driven desktop workflow with tiling and workspaces.
- A coherent shell, status bar, and terminal experience built around upstream tools.
- A reproducible Windows developer environment with portable toolchain definitions.
- Optional Linux and container workspaces through WSL2 and Docker.
- A restrained Moroccan visual identity that does not compromise usability.
- Safe, documented setup, update, backup, restore, and removal paths.

### Non-goals

- Replacing Windows or building a new operating system.
- Reimplementing upstream applications or bundling their binaries without a clear licensing and distribution basis.
- Forcing every optional integration on every user.
- Claiming support for a Windows build, device, distro, or application version that has not been tested.
- Storing credentials, private keys, personal paths, or machine-specific secrets in the repository.

## Roadmap at a glance

| Milestone | Focus | Status | Tracking |
|---|---|---|---|
| M0 | Repository foundation and project identity | **Complete** | Initial scaffold, architecture overview, contributing guide, MIT license |
| M1 | Product scope and architecture | **In progress — decisions drafted, issue checklist incomplete** | [Issue #1](https://github.com/openanaffa/moorishell/issues/1) |
| M2 | Reproducible provisioning and configuration management | **Scaffold only — blocked pending M1 completion** | [Issue #2](https://github.com/openanaffa/moorishell/issues/2) |
| M3 | Core desktop experience | Not started | [Issue #3](https://github.com/openanaffa/moorishell/issues/3) |
| M4 | Portable developer toolchain | Not started | [Issue #4](https://github.com/openanaffa/moorishell/issues/4) |
| M5 | WSL2 and container workspaces | Not started | [Issue #5](https://github.com/openanaffa/moorishell/issues/5) |
| M6 | Brand identity and optional workspace integrations | Not started | [Issue #6](https://github.com/openanaffa/moorishell/issues/6) |
| M7 | Validation, security, compatibility, and recovery | Not started | [Issue #7](https://github.com/openanaffa/moorishell/issues/7) |
| M8 | First preview release | Not started | [Issue #8](https://github.com/openanaffa/moorishell/issues/8) |

## Milestone details

### M0 — Repository foundation

**Status: Complete**

Delivered:
- Public repository and initial project scaffold.
- README, contribution expectations, and initial architecture overview.
- MIT license for original MooriShell materials.

### M1 — Product scope and architecture

Define what MooriShell is, who it serves, and where its responsibilities end.

Key outputs:
- Product scope and core user journeys.
- Supported Windows baseline and minimum assumptions, based on real test systems.
- Core, optional, experimental, and out-of-scope integration classifications.
- Explicit ownership boundaries for upstream tools.
- Architecture decision records for package management, configuration, secrets, and lifecycle behavior.

**Gate:** There is an agreed implementation boundary and no unresolved decision that blocks provisioning.

[Track M1 tasks](https://github.com/openanaffa/moorishell/issues/1)

### M2 — Reproducible provisioning and configuration management

Build the foundation for a predictable setup on clean and existing Windows installations.

Key outputs:
- Dependency catalog and package-manager ownership policy.
- PowerShell bootstrap with prerequisite checks, dry-run mode, logs, and clear errors.
- Idempotent provisioning and configuration application.
- Configuration backup, restore, and uninstall paths.
- Separation of shared defaults, machine-specific overrides, and secrets.

**Gate:** A clean test machine can be configured reproducibly, and re-running or reverting setup is safe.

[Track M2 tasks](https://github.com/openanaffa/moorishell/issues/2)

### M3 — Core desktop experience

Integrate the primary Windows desktop components without replacing Windows.

Initial integration targets:
- Shelled — shell experience.
- Komorebi — tiling and workspaces.
- YASB — status bar.
- WezTerm — terminal and profiles.

Key outputs:
- Versioned configurations and documented startup/lifecycle behavior.
- Consistent shortcut map and dependable workspace/layout profiles.
- Restart and recovery behavior.
- Multi-monitor, mixed-DPI, suspend/resume, and sign-in validation.

**Gate:** The desktop workflow is usable after sign-in, documented, and recoverable if an individual component fails.

[Track M3 tasks](https://github.com/openanaffa/moorishell/issues/3)

### M4 — Portable developer toolchain

Make development tools reproducible across machines.

Planned coverage:
- Runtimes and languages: Python, Node.js, Bun, Go, Rust, Lua, and C/C++.
- Compilers and build tooling, including Clang/LLVM and required Windows build tools.
- Git, GitHub CLI, hooks, extensions, SSH, GPG, and TLS/SSL tooling.
- Bash and PowerShell workflows.
- Zed, VS Code, and GitHub Desktop as optional integrations.
- Portable binaries, PATH policy, and version selection through mise where appropriate.

**Gate:** A documented developer profile can be reproduced, tool versions are inspectable, and credentials remain outside the repository.

[Track M4 tasks](https://github.com/openanaffa/moorishell/issues/4)

### M5 — WSL2 and container workspaces

Make Linux development environments and container workloads portable.

Key outputs:
- WSL2 prerequisite checks, diagnostics, and recovery instructions.
- A defined supported distro baseline.
- Export, import, backup, and restore procedures.
- Evaluation of Ubuntu and NixOS images; Omarchy-on-WSL remains experimental until validated.
- Docker integration and explicit workspace, volume, and filesystem conventions.

**Gate:** A supported Linux environment can be provisioned and recovered, with container data locations clearly documented.

[Track M5 tasks](https://github.com/openanaffa/moorishell/issues/5)

### M6 — Brand identity and optional workspace integrations

Apply the Moorish visual identity to MooriShell-owned surfaces and configurations.

Key outputs:
- Design tokens, typography, iconography, logo, and usage guidance.
- Consistent visual configuration and optional appearance profiles.
- Evaluation of an Obsidian/local knowledge workspace, graph and assistant layout, and Agent Pet.
- Clear separation between core setup and opt-in productivity features.

**Gate:** MooriShell-owned design assets follow a documented system, and optional integrations can be removed independently.

[Track M6 tasks](https://github.com/openanaffa/moorishell/issues/6)

### M7 — Validation, security, compatibility, and recovery

Raise confidence in the full setup and maintenance lifecycle.

Key outputs:
- Disposable VM/clean-machine test procedure.
- Compatibility matrix based on tested versions and devices.
- Automated checks for scripts, manifests, and configuration.
- Install, re-run, update, restore, and uninstall smoke tests.
- Security review of downloads, privilege boundaries, secrets, and destructive operations.
- Troubleshooting guides and documented limitations.

Testing and safety work should begin in M2 and continue throughout development; M7 consolidates and verifies coverage.

**Gate:** Critical setup and recovery paths pass repeatable tests, and unsupported configurations are clearly identified.

[Track M7 tasks](https://github.com/openanaffa/moorishell/issues/7)

### M8 — First preview release

Prepare a truthful preview for external testing.

Key outputs:
- Explicit preview scope and known limitations.
- Complete install, update, backup, restore, and uninstall documentation.
- Versioning, changelog, and release checklist.
- Verified screenshots/demo and issue templates.
- Small tester feedback cycle and a tagged preview.

**Gate:** A new tester can understand, install, use, remove, and report issues against the preview.

[Track M8 tasks](https://github.com/openanaffa/moorishell/issues/8)

## Recommended execution order

1. **M1 first:** settle scope and the decisions that affect every later milestone.
2. **M2 next:** implement the provisioning and configuration foundation.
3. **M3 and M4:** build the desktop workflow and developer environment on top of M2.
4. **M5:** integrate WSL2 and Docker after the Windows-side toolchain policy is clear.
5. **M6:** develop the identity and optional workspace experience without blocking core functionality.
6. **M7 continuously:** test and review safety during every milestone; complete the consolidated validation before preview.
7. **M8 last:** publish only what has passed the release gates.

## How progress is tracked

- Each milestone has one GitHub Issue containing its task checklist and exit criteria.
- Use the issue checkboxes as the live task status; this document is the high-level roadmap.
- Keep issues open while any required task or exit criterion remains incomplete.
- Close a milestone issue only after its exit criteria are met and the relevant behavior is validated.
- Update this document when scope, milestone status, or architecture changes.
- Prefer small pull requests linked to the relevant milestone issue.
- Mark work as experimental when it has not passed its validation gate.

## Current inventory (2026-11-17)

- M1 has six revised ADRs and an aligned architecture overview. Issue #1 currently has its first three tasks checked. The Windows baseline checkbox needs test evidence: ADR-002 defines a Windows 11 x64 policy but deliberately does not claim a tested build floor or minimum hardware. Package source assignments and configuration deployment mappings are M2 implementation work; do not mark them validated merely because the policy is documented.
- M2 has `configs/packages.yaml` and an initial `scripts/install.ps1` scaffold. The script currently fails at startup because it redeclares the common `-Verbose` parameter. Its package download/install behavior is a placeholder, restore/uninstall are incomplete, and the clean-machine and recovery exit criteria have not been validated. GitHub issue #2 remains entirely unchecked.
- M3 has Shelled source customizations in the submodule (quick-launch/battery UI, hotkey bridge, safe-mode command allow-list) and prebuilt Komorebi/WezTerm binaries were used during local experiments. This does not yet establish versioned MooriShell configs, lifecycle/recovery behavior, or the multi-display validation required by issue #3.
- M4–M8 remain planned; no milestone completion evidence is recorded in the repository inventory.
- The submodule URLs in `.gitmodules` are local absolute `F:/sources/...` paths. This is not portable for a clean clone and must be fixed before setup can be reproducible.

## Current next action

Complete and review [M1 - Define product scope and architecture](https://github.com/openanaffa/moorishell/issues/1), then resume M2. Do not mark a GitHub task or exit criterion complete until the implementation and its evidence meet that criterion.
