# Developer orchestration

Use GNU Make as the short command surface and Bun as the typed, locked
developer runtime and dispatcher. The root `package.json`, `bun.lock`, and
`tsconfig.json` define scripts, pinned dev-tool versions, and type checks.
Make delegates to those named Bun scripts (for example `make doctor` is
`bun run doctor`); it does not independently install toolchains.
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

Use `bun install --frozen-lockfile` to reproduce the root developer toolchain,
then `bun run check:types` to type-check the orchestrator. This root install
does not install Shelled's UI or .NET dependencies.

The Bun manifest pins `@types/bun` and TypeScript for a strict type-checking
surface. The orchestrator itself uses only Bun's Node-compatible standard
libraries; it has no runtime third-party dependencies.

The default Shelled source is the portable `src/shelled` submodule. The local
submodule can lag the customized feature branch. For `make ui-focused`, point
`SHELLED_SOURCE` at a full checkout containing
`tests/e2e/quick-settings.e2e.test.js`. Set it in an untracked `.env.local`
(after loading that file into your shell) or in the current PowerShell session:

```powershell
$env:SHELLED_SOURCE = 'F:\sources\shelled'
make ui-focused
```

Do not commit `.env.local`; `.env.example` intentionally contains no machine
path.

## Common tasks

```powershell
make help
make doctor
make plan
make test-safety
make test
make ui-focused
make restore
make ui-install
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
- `make restore` explicitly restores Shelled NuGet packages and may access
  configured package feeds.
- `make ui-install` explicitly installs the Shelled UI lockfile dependencies
  with Bun and may access the registry.
- No command installs software, changes Winlogon/registry settings, or deploys
  user configuration.

The Makefile and Bun runner are an orchestration layer only. When online,
restore the Shelled .NET solution and install the UI package dependencies in
`src/shelled/src/Shell.UI.Web` before running build/test/style targets. These
setup steps intentionally remain manual until package sources and offline
restore policy are validated.
