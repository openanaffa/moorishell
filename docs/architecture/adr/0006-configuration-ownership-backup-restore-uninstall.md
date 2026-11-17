# ADR-006: Configuration ownership, backup, restore, and uninstall

**Status:** Accepted (lifecycle policy); deployment mapping required in M2  
**Date:** 2026-11-17  
**Deciders:** MooriShell project maintainer

## Context
MooriShell needs versioned defaults while preserving user edits and machine-specific settings. The repository must not become the live configuration directory or a storage location for backups, logs, credentials, or machine state.

## Decision

### Ownership and storage
| Configuration/state | Owner | Location | Repository |
|---|---|---|---|
| MooriShell default templates | MooriShell | configs/<app>/ | Committed |
| Per-machine overrides and local state | User | %LOCALAPPDATA%/MooriShell/ | Never committed |
| Deployed application config | User, with explicitly recorded MooriShell-managed baseline | Native application config path | Never repository source |
| Application defaults/binaries | Upstream project | Upstream install/config locations | Not copied into MooriShell |
| Backups and provisioning state | User / MooriShell tooling | %LOCALAPPDATA%/MooriShell/backups/ and state/ | Never committed |
| Logs | User / MooriShell tooling | %LOCALAPPDATA%/MooriShell/logs/ | Never committed |
| Secrets and credentials | User / credential provider | Windows Credential Manager, DPAPI-backed store, or application secret store | Never committed or stored in plain-text MooriShell config |

Machine-specific overrides must live outside the repository. Do not place hostname-specific or user-specific files under configs/, even if gitignored.

### Configuration precedence
1. Upstream application behavior and documented schema remain authoritative.
2. MooriShell supplies versioned defaults only for settings it explicitly owns.
3. User overrides take precedence over MooriShell defaults.
4. Machine-specific values are stored locally and never committed.
5. If an application cannot support layered configuration, MooriShell generates a deployed file from defaults plus overrides and preserves the prior file before changing it.

MooriShell must document the destination path and ownership mode for every deployed file. It must not claim ownership of unrelated settings in the same application configuration.

### Backup and state tracking
Before changing a destination, M2 must record whether it existed, capture pre-change content/metadata, create a timestamped backup outside the repository, and record source, destination, prior hash, deployed hash, and operation in a local state manifest. Abort or request explicit resolution when a destination has changed since the last MooriShell deployment.

Backups exclude secrets unless the user explicitly uses an application-native encrypted backup mechanism. Do not copy credential stores into ordinary backup archives.

### Update behavior
- Pulling repository changes does not itself modify live application configuration.
- Applying an update is explicit.
- If the deployed file is unchanged from the last MooriShell version, it may be backed up and updated.
- If the user has edited the deployed file, preserve it and report a conflict; do not overwrite automatically.

### Restore and uninstall
- Restore operates only on paths recorded in MooriShell's local state manifest and requires an identifiable backup.
- Uninstall removes only files created by MooriShell that are still byte-for-byte equal to the recorded deployed version.
- If a managed file has been modified by the user, leave it in place and report it for manual review.
- If MooriShell replaced a pre-existing file, restore the captured original only after preserving subsequent user edits and obtaining explicit confirmation where overwrite is possible.
- Never remove upstream applications, user data, secrets, unrelated configuration, or the cloned MooriShell repository. Uninstall must not delete repository configs/, scripts/, or docs/.

## Consequences
- The repository is the source for MooriShell defaults, not live machine state.
- Backups, logs, overrides, and deployment state remain local and outside version control.
- Safe restore/uninstall requires a state manifest and hash-based ownership checks; M2 must implement these before claiming reversibility.

## Alternatives considered
- **Store user overrides under configs/:** Rejected because it mixes shared defaults with private machine state and risks accidental commits.
- **Delete all known application config directories on uninstall:** Rejected because those directories may contain user-owned settings and unrelated data.
- **Automatically overwrite changed configuration:** Rejected because it destroys user changes and makes rollback unreliable.

## Related
ADR-004, ADR-005; Roadmap M2: https://github.com/openanaffa/moorishell/issues/2
