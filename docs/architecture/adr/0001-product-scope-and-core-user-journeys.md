# ADR-001: Product scope and core user journeys

**Status:** Accepted  
**Date:** 2026-11-16  
**Deciders:** MooriShell project maintainer

## Context

MooriShell is in early experimental stage (M0 complete). The roadmap requires M1 to define product scope before M2 provisioning can begin. The existing README and architecture overview list several tools (Shelled, Komorebi, YASB, WezTerm, WSL2, Docker, Scoop/WinGet/Chocolatey, mise, Bun/Node.js/Rust/Go/C/C++) but do not yet define which are core vs optional vs experimental, nor what a coherent user journey looks like.

## Decision

MooriShell is a **Windows-native desktop workspace** that assembles existing applications into a coherent, keyboard-driven environment. It does not replace Windows and does not reimplement upstream tools.

### Core user journeys

1. **Log in to a coherent desktop:** Shelled is the shell host; Komorebi manages tiling/workspaces; YASB provides the status bar; WezTerm is the terminal. After sign-in, the user should land in a usable tiled desktop with status bar and quick terminal access.
2. **Launch and manage terminal sessions:** WezTerm is launched via Shelled launcher or keyboard shortcut; Komorebi tiles it; user can switch focus with Alt+Arrows and workspaces with Alt+1-9 / Alt+Shift+1-9.
3. **Configure and customize:** User edits MooriShell-owned configuration files (not upstream binaries) to change keybindings, layout rules, status bar widgets, and terminal profiles.
4. **Install and update tools:** User installs core tools via package manager (policy defined in ADR-005); optional tools are opt-in.
5. **Recover or remove:** User can run uninstall/restore to revert MooriShell-owned configuration without touching upstream tools or personal data.

### Non-goals for M1

- Replacing Windows Explorer as the system shell (Winlogon `Shell` registry change).
- Bundling upstream binaries.
- Supporting WSL2/Docker container workspaces (M5).
- Building new applications or forking upstream projects.

## Consequences

### Positive

- Clear boundary between MooriShell-owned configuration and upstream tools.
- Users can adopt incrementally (e.g., just Komorebi + YASB without Shelled as shell).
- Installation/uninstallation is bounded and reversible.

### Negative

- Shelled is not yet a production shell replacement; users must launch it manually (dev mode) rather than having it auto-start via Winlogon.
- Some integration gaps (e.g., WezTerm launch path) require manual configuration until M2 provisioning exists.

## Alternatives considered

### Replace Windows Explorer as shell (Winlogon)

Rejected for M1. Shelled is not yet stable enough to be the default shell; doing so would break Komorebi/Yasb Explorer-dependent integration and risk locking users out. Real-shell registration is deferred to a later milestone after dev-mode evaluation.

### Build a new window manager from scratch

Rejected. Komorebi already provides tiling; integrating it aligns with the principle of integrating upstream tools rather than duplicating them.

## Related

- ADR-003: Integration tier classification
- ADR-004: Ownership boundaries
- Roadmap M1: https://github.com/openanaffa/moorishell/issues/1
