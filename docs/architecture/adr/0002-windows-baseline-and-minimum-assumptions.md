# ADR-002: Supported Windows baseline and minimum assumptions

**Status:** Revised (experimental-host policy); exact supported baseline pending validation
**Date:** 2026-11-17  
**Deciders:** MooriShell project maintainer

## Context
A support statement must distinguish the intended platform from builds and hardware actually tested. The repository does not yet contain sufficient evidence to claim a precise Windows build floor or minimum hardware specification.

## Decision

### Baseline policy
| Component | Baseline |
|---|---|
| Operating system | Windows 11 x64 is the intended supported baseline; custom Windows images and Windows 10-derived systems are experimental and unsupported |
| Servicing | Microsoft servicing status is recorded as a risk, not used as a proxy for project compatibility; the project may test unsupported builds without claiming support |
| Architecture | x86_64 |
| Shell mode | Explorer remains active; Shelled runs in development mode |
| Core desktop | Shelled, Komorebi, YASB, WezTerm |
| Automation | PowerShell 7.3+ target; exact compatibility must be tested |
| Privileges | User scope by default; elevation only where a feature requires it |
| Network | Internet access required for initial downloads and updates |

### Explicit limitations
- Stock Windows 10 and ARM64 are not supported targets. Custom Windows 10-derived images, including Tiny11/UUP Dump builds, remain experimental and unsupported unless separately validated and explicitly promoted.
- No exact minimum Windows build, CPU, RAM, display, or DPI requirement is claimed until recorded from a reproducible test system.
- No support claim is made for Windows Server.
- Registering Shelled as the Winlogon shell is unsupported; scripts must not modify the Winlogon Shell value.

### Validation requirement
Record Windows edition, display version, OS build, architecture, PowerShell version, and relevant hardware in a compatibility record. Update the supported build floor only after clean-install and recovery tests pass.

#### Current development-host observation (2026-11-17)
The maintainer identifies the current OS as a **custom Tiny11 image built with UUP Dump**, based on **Windows 10 Pro N**, with selected Windows 11 components used to support some applications and services. Local APIs reported conflicting product labels while agreeing on build `22621`: `Win32_OperatingSystem` reported Microsoft Windows 11 Pro N, while the current-version registry reported Windows 10 Pro N, display version `22H2`, build `22621`, UBR `4317`; `[Environment]::OSVersion` reported `10.0.22621.0`. This is expected to be a hybrid/custom image and must not be represented as stock Windows 11.

Reported hardware: Dell Precision M6700, x64, Intel Core i7-3840QM (4 cores/8 logical processors), 24 GiB RAM, NVIDIA Quadro K4000M and Intel HD Graphics 4000, UEFI. This records one experimental development host only; it does not establish minimum hardware requirements or prove clean-install/recovery compatibility.

The maintainer accepts Microsoft's Windows 10 end-of-support status as a known risk and does not require Microsoft support as a project-go/no-go criterion. MooriShell still does not claim this custom image as supported. The target remains stock Windows 11 x64; this host may be used for experimental validation, with results labeled by its actual custom image and build.

## Consequences
- The project distinguishes its intended baseline from custom/unsupported experimental hosts, regardless of Microsoft's servicing status.
- Exact build and hardware minimums remain an M1 validation gap, not an invented specification.

## Alternatives considered
- **Windows 11 21H2 or later:** Rejected as a blanket support statement; a historical minimum does not guarantee the release is still serviced or tested.
- **Support Windows 10 and ARM64 immediately:** Deferred until the x64 workflow is reliable.

## Related
ADR-001, ADR-003; Roadmap M1: https://github.com/openanaffa/moorishell/issues/1
