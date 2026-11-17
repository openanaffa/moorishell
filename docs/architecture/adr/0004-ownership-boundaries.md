# ADR-004: Ownership boundaries for upstream tools

**Status:** Accepted  
**Date:** 2026-11-16  
**Deciders:** MooriShell project maintainer

## Context

MooriShell integrates multiple upstream tools (Shelled, Komorebi, YASB, WezTerm, WSL2, Docker, package managers, toolchains). The roadmap (M1) requires explicit ownership boundaries. The contributing guide states: "Keep MooriShell-specific changes separate from upstream defaults" and "Do not copy or redistribute upstream source code, assets or binaries without checking the applicable license and attribution requirements."

## Decision

### Ownership model

| What | Owner | MooriShell responsibility |
|---|---|---|
| Upstream executables and source code | Upstream project | None; link to official install documentation |
| Upstream release cycles and licenses | Upstream project | None; document versions used |
| MooriShell configuration files | MooriShell | Author, maintain, version |
| MooriShell scripts and automation | MooriShell | Author, maintain, test |
| MooriShell documentation | MooriShell | Author, maintain |
| User machine-specific settings | User | None; MooriShell does not commit them |
| User secrets and credentials | User | None; never stored in repository |

### What MooriShell does NOT do

- Modify upstream source code or redistribute upstream binaries without license review.
- Fork upstream projects unless explicitly decided and licensed.
- Store user credentials, private keys, personal paths, or machine-specific secrets in the repository.
- Assume ownership of upstream application updates (user controls when to upgrade upstream tools).

### Configuration ownership

MooriShell owns its own configuration files stored in `configs/`. These files:
- Reference upstream applications by version where known.
- Are separate from upstream default configurations.
- Document required dependencies and installation steps.
- Are tested before being considered complete.

### Startup and lifecycle ownership

MooriShell documents how each upstream component is started and stopped:
- Shelled: launched manually in dev mode (SHELL_DEV_MODE=1); not registered as Winlogon shell.
- Komorebi: launched by user or automation; manages window tiling.
- YASB: launched by user or automation; renders status bar.
- WezTerm: launched via Shelled launcher or user action; terminal emulator.

MooriShell does not supervise or restart upstream processes automatically in M1.

## Consequences

### Positive

- Clear separation between MooriShell-owned and upstream-owned code.
- Users can remove MooriShell configuration without affecting upstream installations.
- Upstream updates are controlled by the user, not forced by MooriShell.

### Negative

- Users must manually launch components (Shelled, Komorebi, YASB, WezTerm) until M2 provisioning automates startup.
- No automatic restart if a component crashes.

## Alternatives considered

### Fork and modify upstream tools

Rejected. Violates the principle of respecting upstream projects and adds maintenance burden.

### Make MooriShell responsible for upstream updates

Rejected. Users should control their own tool versions; MooriShell documents versions but does not enforce them.

## Related

- ADR-003: Integration tier classification
- ADR-005: Package-manager ownership policy
- Roadmap M1: https://github.com/openanaffa/moorishell/issues/1
