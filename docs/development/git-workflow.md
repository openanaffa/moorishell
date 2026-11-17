# Git workflow and worktrees

MooriShell uses a lightweight Git Flow naming convention. The default branch
is `main`; do not commit feature work directly to it.

## Branch types

| Prefix | Use | Example |
|---|---|---|
| `feature/` | New capability | `feature/zed-project-setup` |
| `bugfix/` | Fix for unreleased work | `bugfix/install-plan-exit-code` |
| `hotfix/` | Urgent fix against a release | `hotfix/preview-startup` |
| `release/` | Stabilize a release candidate | `release/0.1.0-preview.1` |
| `docs/` | Documentation-only work | `docs/offline-toolchain-inventory` |

Use short kebab-case names and link issue numbers in branch names or commits
when useful, e.g. `feature/42-safe-provisioning`. Prefer Conventional Commit
messages (`feat:`, `fix:`, `docs:`, `test:`, `chore:`). Pull requests target
`main`; squash or rebase according to repository policy, keeping history
reviewable. `main` should remain usable and pushed feature branches should be
short-lived.

## Git configuration

Run once per clone:

```powershell
git config --local pull.rebase true
git config --local fetch.prune true
git config --local init.defaultBranch main
```

For a standard Git Flow mapping, `main` is the production/release branch and
`develop` is the integration branch when one is introduced. This repository
does not currently have `develop`; feature branches are based on `origin/main`
until the maintainer creates that integration branch. Do not create an empty
`develop` branch solely to satisfy the classic model.

The repository's `main` branch tracks `origin/main`. Avoid configuring a
global Git Flow extension or changing user-wide identity from project scripts.

## Worktree workflow

Worktrees keep parallel tasks in separate directories while sharing the same
Git object database. Prefer sibling directories under `F:\sources\worktrees\`
so worktree contents do not enter the repository or its submodules.

Create a new feature branch and worktree:

```powershell
git worktree add -b feature/<name> F:\sources\worktrees\<name> origin/main
```

Create a worktree for an existing branch:

```powershell
git worktree add F:\sources\worktrees\<name> <branch>
```

List and clean up:

```powershell
git worktree list
git worktree remove F:\sources\worktrees\<name>
git worktree prune
```

Do not force-remove a worktree with uncommitted changes. Before removing it,
check `git -C <path> status --short` and preserve or commit useful work. A
branch can only be checked out in one worktree at a time.

Submodules in a newly created worktree:

```powershell
git -C F:\sources\worktrees\<name> submodule update --init --recursive
```

## Helper

`scripts/worktree.ps1` wraps common operations with validation. Run
`Get-Help .\scripts\worktree.ps1 -Examples` for usage. The helper never
force-removes worktrees and never deletes branches automatically.
