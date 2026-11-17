# ADR-003: Integration tier classification

**Status:** Accepted  
**Date:** 2026-11-17  
**Deciders:** MooriShell project maintainer

## Context
MooriShell combines desktop components, developer tools, package managers, and optional workspace applications. Optional tooling must not become a hidden core dependency.

## Decision

### Tier definitions
| Tier | Meaning |
|---|---|
| **Core** | Required for the primary desktop workflow; receives maintained configuration and validation. |
| **Optional** | User opt-in; core functionality remains usable without it. |
| **Experimental** | Evaluated or supported only in a limited profile; may change or be removed. |
| **Out of scope** | Not provided or managed by MooriShell. |

### Current assignments
| Component | Tier | Responsibility |
|---|---|---|
| Shelled | Core | Desktop entry point, development mode only |
| Komorebi | Core | Tiling and workspaces |
| YASB | Core | Status bar |
| WezTerm | Core | Terminal |
| PowerToys | Optional | Windows utilities/launcher; avoid overlapping ownership with Komorebi |
| WSL2 | Optional | Linux userland |
| Docker | Optional | Container workloads |
| Obsidian and other knowledge apps | Optional | User-selected productivity layer |
| Zed, VS Code, GitHub Desktop | Optional | Developer GUI tools |
| Scoop / WinGet | Provisioning backends | Per-package ownership governed by ADR-005 |
| Chocolatey | Experimental backend | Explicit exception only; not a default source |
| mise | Optional developer profile | Runtime version management |
| Python, Node.js, Bun, Rust, Go, Lua, C/C++ | Developer profile | M4 toolchain scope; not core desktop dependencies |
| Cygwin | Experimental | Evaluate only if native tools or WSL2 do not meet a required workflow |
| Winlogon shell replacement | Out of scope | No Explorer replacement |

### Classification rules
1. Core integrations need documented install/configuration/startup and recovery behavior before being called supported.
2. Optional integrations require explicit opt-in and must be independently removable.
3. Experimental components must not be required by core setup.
4. Package managers are provisioning mechanisms, not user-facing integrations.
5. A tier is a project commitment level, not a claim that every version/platform combination has been tested.

## Consequences
- The desktop can be provisioned without WSL2, Docker, PowerToys, or developer toolchains.
- PowerToys and Komorebi may overlap; MooriShell must document which tool owns each shortcut/behavior.
- Developer tools can be provisioned as a separate opt-in profile.

## Related
ADR-001, ADR-004, ADR-005; Roadmap M1: https://github.com/openanaffa/moorishell/issues/1
