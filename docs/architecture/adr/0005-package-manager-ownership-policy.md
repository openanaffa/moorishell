# ADR-005: Package-manager ownership policy

**Status:** Accepted (policy); package assignments require validation  
**Date:** 2026-11-17  
**Deciders:** MooriShell project maintainer

## Context
Windows may have Scoop, WinGet, and Chocolatey simultaneously. A single global manager would reduce flexibility, while allowing all managers to install the same package creates duplicate installations, PATH ambiguity, and conflicting update ownership. MooriShell also values portable, user-scoped tools.

## Decision

### Policy: one authoritative source per package
1. MooriShell does not mandate one global package manager.
2. Every managed dependency declares exactly one authoritative source and update owner in the manifest.
3. A package must not be installed or updated through a second manager while its declared owner is active. Detect existing installations and report conflicts; do not silently duplicate or migrate them.
4. Prefer user-scoped and portable installs where they meet the application's requirements.
5. Runtime version management is separate from application package management. mise may own runtimes explicitly assigned to it; do not also manage those runtime versions elsewhere.
6. Installation, update, migration, and removal are explicit user-invoked operations. No background package updates.

### Source selection defaults
| Source | Preferred use | Policy |
|---|---|---|
| **Scoop** | User-scoped CLI tools and portable developer utilities | Preferred when a maintained manifest and suitable portable artifact exist |
| **WinGet** | Windows-native GUI applications, Microsoft components, and installers requiring standard registration | Preferred when Scoop is unsuitable or vendor installation is required |
| **Direct official release** | Portable archives or vendor downloads where package-manager packaging is unsuitable | Pin/version-check artifacts; verify checksums/signatures when published |
| **Chocolatey** | Existing user-managed installs or documented package-specific exception | Not a default MooriShell source; never duplicate a Scoop/WinGet-owned package |
| **mise** | Language runtimes/tool versions explicitly assigned to mise | Runtime owner only; not a general Windows application manager |

These are selection defaults, not a claim that every package is available or validated through that source.

### Manifest contract
Each managed package entry must include a stable ID/name, one source type and authoritative package identifier, version policy/resolved version, install scope, install method, expected executable/path for detection, update/uninstall behavior, and verification data (official source and checksum/signature where available).

A package with no validated source remains manual/not-managed; the bootstrapper must not treat it as successfully installed.

## Consequences
- The catalog, not whichever package manager happens to be installed, determines ownership.
- Scoop is preferred for suitable portable/user-scope tools; WinGet covers native installers; Chocolatey remains an explicit exception.
- M2 must detect conflicting pre-existing installations and stop for user choice rather than create duplicates.
- Current catalog entries marked direct/direct_download are provisional metadata, not evidence that the bootstrapper can install those tools.

## Alternatives considered
- **Choose WinGet globally:** Rejected because it does not consistently provide the desired portable/user-scope behavior.
- **Support all managers equally for every package:** Rejected because it multiplies test paths and makes update ownership ambiguous.
- **Allow the first available manager to win:** Rejected because behavior would vary by machine.

## Related
ADR-003, ADR-004; Roadmap M2: https://github.com/openanaffa/moorishell/issues/2
