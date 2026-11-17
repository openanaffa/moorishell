# ADR-003: Integration tier classification

**Status:** Accepted  
**Date:** 2026-11-16  
**Deciders:** MooriShell project maintainer

## Context

MooriShell integrates multiple upstream tools. The roadmap (M1) requires classifying integrations as core, optional, experimental, or out-of-scope. The README already lists several tools with status annotations, but they are not yet formally classified.

## Decision

### Tier definitions

| Tier | Meaning | Example (current) |
|---|---|---|
| **Core** | Essential to the MooriShell experience; configured and documented by MooriShell; included in provisioning. | Shelled, Komorebi, YASB, WezTerm |
| **Optional** | Useful but not required; user opts in; documented setup provided. | WSL2, Docker |
| **Experimental** | Under evaluation; may change or be removed without notice; no production support. | Scoop/WinGet/Chocolatey, mise, Bun/Node.js/Rust/Go/C/C++ toolchains |
| **Out of scope** | Explicitly not part of MooriShell. | Winlogon `Shell` registry changes (real shell replacement), upstream tool forks |

### Tier assignments

| Tool | Tier | Rationale |
|---|---|---|
| Shelled | Core | Shell host; central to the MooriShell experience |
| Komorebi | Core | Tiling and window management |
| YASB | Core | Status bar |
| WezTerm | Core | Terminal emulator |
| WSL2 | Optional | Linux userland; not required for core Windows desktop |
| Docker | Optional | Container workloads; not required for core Windows desktop |
| Scoop / WinGet / Chocolatey | Experimental | Package managers under evaluation; no ownership policy yet (see ADR-005) |
| mise | Experimental | Runtime version manager under evaluation |
| Bun, Node.js, Rust, Go, C/C++ | Experimental | Developer toolchains; covered by M4 |
| Winlogon `Shell` replacement | Out of scope | Shelled runs in dev mode; real shell replacement is deferred |

### Classification rules

1. **Core** integrations ship with documented configuration, startup, and recovery behavior.
2. **Optional** integrations require explicit user opt-in; their absence does not degrade core functionality.
3. **Experimental** integrations may change behavior, package names, or be removed without deprecation notice.
4. **Out of scope** items are explicitly not the responsibility of MooriShell.

## Consequences

### Positive

- Users know which components are stable vs experimental.
- Core integrations receive priority for documentation and testing.
- Out-of-scope items (e.g., Winlogon replacement) are explicitly ruled out, preventing scope creep.

### Negative

- Users who want real-shell replacement must wait for a future milestone.
- Experimental package managers may change behavior between versions.

## Alternatives considered

### Make all integrations "core"

Rejected. WSL2, Docker, and package managers are not required for the core desktop workflow and would add unnecessary complexity to M2 provisioning.

### Make all integrations "optional"

Rejected. Shelled, Komorebi, YASB, and WezTerm are the core experience; making them optional would make MooriShell meaningless.

## Related

- ADR-001: Product scope and core user journeys
- ADR-005: Package-manager ownership policy
- Roadmap M1: https://github.com/openanaffa/moorishell/issues/1
