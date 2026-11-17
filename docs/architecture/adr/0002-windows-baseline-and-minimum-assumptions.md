# ADR-002: Supported Windows baseline and minimum assumptions

**Status:** Accepted  
**Date:** 2026-11-16  
**Deciders:** MooriShell project maintainer

## Context

MooriShell targets Windows 11. The roadmap (M1) requires defining "Supported Windows baseline and minimum assumptions, based on real test systems." The existing environment is Windows 11 with Shelled running in dev mode alongside Explorer.

## Decision

### Supported baseline

| Component | Requirement |
|---|---|
| Operating system | Windows 11 (21H2 or later), 64-bit |
| Architecture | x86_64 |
| Shell under test | Explorer remains active; Shelled runs in dev mode (SHELL_DEV_MODE=1) |
| Terminal | WezTerm |
| Tiling WM | Komorebi |
| Status bar | YASB |
| Package management | Scoop, WinGet, Chocolatey (under evaluation — see ADR-005) |
| Runtime management | mise (under evaluation) |

### Minimum assumptions

- The user has administrator rights for initial tool installation.
- PowerShell 7+ is available for automation scripts.
- Git is installed for cloning submodules.
- The user has network access to download upstream binaries.
- Display: single or multi-monitor; no specific DPI requirement stated, but multi-monitor and mixed-DPI must be validated in M3/M7.
- No specific language/locale requirement; documentation is English.

### Explicitly NOT supported (M1)

- Windows 10.
- Windows Server editions.
- ARM64 architecture.
- Running Shelled as the real shell (Winlogon `Shell` value) — dev mode only.
- Any configuration that modifies the Winlogon registry `Shell` value without explicit user authorization.

## Consequences

### Positive

- Clear target for testing and CI.
- Users on unsupported configurations know they are outside scope.
- Simplifies Komorebi/YASB integration testing (Explorer remains active).

### Negative

- Users on Windows 10 or ARM64 cannot use MooriShell out of the box.
- Real-shell replacement is explicitly deferred; dev mode is the only supported mode.

## Alternatives considered

### Support Windows 10 as baseline

Rejected. Komorebi and other tooling targets Windows 10+ features; limiting to Windows 11 avoids testing burden and aligns with the project's experimental scope.

### Make Shelled the real shell in M1

Rejected. Dev mode is safer for evaluation and does not break Komorebi/Yasb Explorer-dependent integration.

## Related

- ADR-001: Product scope and core user journeys
- ADR-004: Ownership boundaries
- Roadmap M1: https://github.com/openanaffa/moorishell/issues/1
