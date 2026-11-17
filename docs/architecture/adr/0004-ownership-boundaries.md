# ADR-004: Ownership boundaries for upstream tools

**Status:** Accepted  
**Date:** 2026-11-17  
**Deciders:** MooriShell project maintainer

## Context
MooriShell configures upstream applications but must not blur responsibility for their code, releases, settings, and runtime behavior.

## Decision

### Ownership model
| Area | Owner | MooriShell responsibility |
|---|---|---|
| Upstream executables, source, assets, releases, licenses | Upstream project | Select documented versions/sources; respect upstream terms |
| MooriShell defaults, scripts, manifests, docs, tests, branding | MooriShell | Author, version, validate, maintain |
| Installed application runtime and native behavior | Upstream application | Configure only through documented interfaces |
| User edits and machine-specific settings | User | Preserve; never commit or silently overwrite |
| Secrets and credentials | User / credential provider | Never collect into repository or plain-text config |
| Package installation/update operation | One declared source per package | Invoke only the source declared in the manifest; see ADR-005 |

### Application-level ownership
- **Shelled:** upstream owns the shell host; MooriShell owns its integration settings and launch instructions.
- **Komorebi:** upstream owns window-management behavior; MooriShell owns its selected keybinding/layout profile. Avoid competing shortcut definitions with PowerToys.
- **YASB:** upstream owns the bar framework; MooriShell owns its selected widgets/theme configuration.
- **WezTerm:** upstream owns the terminal; MooriShell owns its terminal profile and integration defaults.
- **PowerToys, WSL2, Docker, and developer applications:** optional integrations; MooriShell owns only explicit configuration/adapters, not their lifecycle beyond documented setup.

### Runtime and lifecycle boundary
MooriShell may install or update a package only through its declared source and only when the user invokes the operation. It may start core applications through documented startup mechanisms once M3 defines and tests them. It does not patch upstream binaries, silently update upstream tools, or promise process supervision/restart until implemented and validated.

## Consequences
- Upstream projects retain control of their code and release cycles.
- MooriShell can version a coherent configuration without claiming ownership of the configured application.
- Each integration needs an explicit configuration path, startup contract, and recovery behavior before it is considered complete.

## Alternatives considered
- **Fork upstream tools by default:** Rejected due to maintenance and licensing burden.
- **Let MooriShell update all upstream tools automatically:** Rejected; updates are explicit and use the declared package source.

## Related
ADR-003, ADR-005, ADR-006; Roadmap M1: https://github.com/openanaffa/moorishell/issues/1
