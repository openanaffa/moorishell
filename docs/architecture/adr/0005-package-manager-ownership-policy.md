# ADR-005: Package-manager ownership policy

**Status:** Accepted  
**Date:** 2026-11-16  
**Deciders:** MooriShell project maintainer

## Context

The roadmap (M1) requires selecting a package-manager ownership policy. The README lists Scoop, WinGet, and Chocolatey as "tooling under evaluation." The architecture overview states: "Scoop, WinGet and Chocolatey are being evaluated. No final ownership policy has been selected" and "Avoid managing the same application through multiple package managers unless there is a documented reason."

## Decision

### Policy

1. **No default package manager is selected in M1.** Scoop, WinGet, and Chocolatey remain under evaluation.
2. **MooriShell does not install or manage packages automatically in M1.** Users install upstream tools manually using their preferred method, following upstream installation documentation.
3. **No application is managed through more than one package manager** unless a documented reason exists (e.g., a tool is only available via one manager).
4. **A future tool manifest** (M2) will identify the chosen source and update mechanism for each dependency, once a package manager is selected.

### Rationale

- Multiple package managers on one system can conflict (e.g., file path overlaps, duplicate installations).
- Selecting a package manager prematurely would lock users into an ecosystem they may not prefer.
- M2 provisioning will define the package-manager policy once evaluation is complete.

### Future state (M2)

A tool manifest (`configs/` or `toolchain/`) will list each dependency with:
- Package name
- Preferred source (Scoop / WinGet / Chocolatey / direct download / portable binary)
- Version pin or version range
- Install command
- Update mechanism

## Consequences

### Positive

- Avoids package-manager conflicts on user systems.
- Users retain freedom to choose their preferred package manager.
- MooriShell avoids maintaining packaging logic for multiple ecosystems.

### Negative

- Users must manually install core tools (Shelled, Komorebi, YASB, WezTerm) until M2 provisioning exists.
- No automated dependency resolution in M1.

## Alternatives considered

### Select WinGet as default package manager in M1

Rejected. WinGet is Microsoft-native but may not have all required packages; selecting it prematurely limits flexibility.

### Support all three package managers equally in M1

Rejected. This would require testing and documenting three installation paths for every tool, adding maintenance burden without clear benefit.

### Defer package-manager decision to M2

Selected. Keeps M1 focused on scope and architecture rather than tooling logistics.

## Related

- ADR-003: Integration tier classification
- Roadmap M1: https://github.com/openanaffa/moorishell/issues/1
- Roadmap M2: https://github.com/openanaffa/moorishell/issues/2
