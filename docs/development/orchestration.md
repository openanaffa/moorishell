# Developer orchestration

Use GNU Make as the short command surface and Bun as the cross-task dispatcher.
PowerShell, npm, dotnet, and Git remain the implementation tools for the tasks
they already own; the orchestrator only validates prerequisites and forwards
arguments/exit codes.

## Prerequisites

- Bun
- GNU Make
- PowerShell 7 (`pwsh`)
- Git
- Node/npm for Shelled UI tasks
- .NET 8 SDK for Shelled builds
- Restored NuGet assets for the Shelled solution
- Shelled UI `node_modules` (Bun or npm install) for UI tests/styles

## Common tasks

```powershell
make help
make doctor
make plan
make test-safety
make test
make ui-focused
make build
make styles
make worktree-list
```

Create a feature worktree (the name is lowercase kebab-case; branch defaults
to `feature/<name>`):

```powershell
make worktree-new ARGS="quick-settings"
```

Or select the branch name explicitly:

```powershell
make worktree-new ARGS="quick-settings feature/shell-quick-settings"
```

Remove a clean worktree while keeping its branch:

```powershell
make worktree-remove ARGS="quick-settings"
```

The worktree helper refuses to remove dirty trees. It never force-removes a
tree or deletes a branch. Inspect worktrees manually with `git worktree list`.

## Safety contract

- `make plan` is read-only and offline.
- `make test` runs safety tests and the Shelled UI tests; it may report known
  baseline test failures in the Node/jsdom E2E harness. It stops early with
  setup guidance if the UI dependency tree is absent.
- `make ui-focused` runs the Quick Settings regression test only.
- `make build` builds the existing Shelled solution with `--no-restore`; it
  does not download packages and needs existing `project.assets.json` files.
- No command installs software, changes Winlogon/registry settings, or deploys
  user configuration.

The Makefile and Bun runner are an orchestration layer only. When online,
restore the Shelled .NET solution and install the UI package dependencies in
`src/shelled/src/Shell.UI.Web` before running build/test/style targets. These
setup steps intentionally remain manual until package sources and offline
restore policy are validated.
