# ADR-002: Supported Windows baseline and minimum assumptions

**Status:** Accepted (baseline policy); exact build floor pending validation  
**Date:** 2026-11-17  
**Deciders:** MooriShell project maintainer

## Context
A support statement must distinguish the intended platform from builds and hardware actually tested. The repository does not yet contain sufficient evidence to claim a precise Windows build floor or minimum hardware specification.

## Decision

### Baseline policy
| Component | Baseline |
|---|---|
| Operating system | Windows 11, x64 |
| Servicing | A Windows 11 release still within Microsoft's servicing support |
| Architecture | x86_64 |
| Shell mode | Explorer remains active; Shelled runs in development mode |
| Core desktop | Shelled, Komorebi, YASB, WezTerm |
| Automation | PowerShell 7.3+ target; exact compatibility must be tested |
| Privileges | User scope by default; elevation only where a feature requires it |
| Network | Internet access required for initial downloads and updates |

### Explicit limitations
- Windows 10 and ARM64 are not current supported targets.
- No exact minimum Windows build, CPU, RAM, display, or DPI requirement is claimed until recorded from a reproducible test system.
- No support claim is made for Windows Server.
- Registering Shelled as the Winlogon shell is unsupported; scripts must not modify the Winlogon Shell value.

### Validation requirement
Record Windows edition, display version, OS build, architecture, PowerShell version, and relevant hardware in a compatibility record. Update the supported build floor only after clean-install and recovery tests pass.

## Consequences
- The project avoids claiming compatibility with obsolete or untested Windows releases.
- Exact build and hardware minimums remain an M1 validation gap, not an invented specification.

## Alternatives considered
- **Windows 11 21H2 or later:** Rejected as a blanket support statement; a historical minimum does not guarantee the release is still serviced or tested.
- **Support Windows 10 and ARM64 immediately:** Deferred until the x64 workflow is reliable.

## Related
ADR-001, ADR-003; Roadmap M1: https://github.com/openanaffa/moorishell/issues/1
