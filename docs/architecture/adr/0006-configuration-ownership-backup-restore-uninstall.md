# ADR-006: Configuration ownership, secrets, backup, restore, and uninstall behavior

**Status:** Accepted  
**Date:** 2026-11-16  
**Deciders:** MooriShell project maintainer

## Context

The roadmap (M1) requires defining "Configuration ownership, machine-specific overrides, secrets, backup, restore, and uninstall behavior." The architecture overview states: "Before adding automation, define: Where each application's configuration lives. Which tool is authoritative when two tools overlap. How configuration is backed up and restored. How updates are applied and validated. How users can disable or remove an integration."

## Decision

### Configuration ownership

| Configuration type | Owner | Storage location | Committed to repo? |
|---|---|---|---|
| MooriShell-owned configuration | MooriShell | `configs/` | Yes |
| Application defaults | Upstream project | Application install directory | No |
| User customizations | User | `configs/<app>.user.json` or equivalent | No |
| Machine-specific overrides | User | Machine-local only | No |
| Secrets (tokens, keys, passwords) | User | Outside repository | Never |

### Machine-specific overrides

Machine-specific overrides (e.g., monitor-specific geometry, user-specific paths) are stored outside the repository, preferably in `configs/<app>.user.<hostname>.json` or equivalent, and are never committed.

### Secrets

Secrets (API tokens, private keys, passwords, credentials) are never stored in the repository. Users provide them at runtime via environment variables, secret managers, or application-specific secret stores.

### Backup and restore

MooriShell-owned configuration files in `configs/` are the source of truth. Users back up their machine-specific overrides and secrets separately. MooriShell does not provide automated backup/restore in M1; users copy configuration files manually.

### Uninstall behavior

MooriShell uninstall removes only MooriShell-owned files:
- Configuration files in `configs/`
- Scripts in `scripts/`
- Documentation in `docs/`

MooriShell does NOT:
- Remove upstream applications (Komorebi, YASB, WezTerm, etc.)
- Remove user customizations outside the repository
- Remove user secrets or credentials
- Modify the Winlogon `Shell` registry value (Shelled runs in dev mode)

### Update behavior

MooriShell does not automatically update upstream tools in M1. Users control when to upgrade upstream components. MooriShell configuration files are versioned in the repository; users pull updates and apply them manually.

## Consequences

### Positive

- Users retain full control over their machine and upstream tools.
- No secrets or personal data in the repository.
- Uninstall is safe and reversible.

### Negative

- Users must manually back up their configuration and secrets.
- No automated backup/restore in M1.
- Users must manually update upstream tools.

## Alternatives considered

### Automated backup/restore in M1

Rejected. Adds complexity before the core provisioning workflow (M2) is defined. Manual backup/restore is sufficient for the experimental stage.

### Storing encrypted secrets in the repository

Rejected. Violates the principle of never storing secrets in the repository.

### Automatic application updates

Rejected. Users should control their own tool versions; MooriShell documents versions but does not enforce them.

## Related

- ADR-003: Integration tier classification
- ADR-004: Ownership boundaries
- Roadmap M1: https://github.com/openanaffa/moorishell/issues/1
- Roadmap M2: https://github.com/openanaffa/moorishell/issues/2
