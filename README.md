# MooriShell

**A Moorish take on the Windows desktop.**

[MooriShell](https://m7r.is-cool.dev/moorishell) is an experimental, Windows-native desktop workspace inspired by Linux tiling workflows and Moroccan design.
It brings existing tools together through configuration, automation and documentation rather than replacing Windows or reimplementing upstream projects.

The goal is a coherent, keyboard-driven environment that remains practical for everyday Windows use and software development.

## Project status

**Early experiment — not yet a stable distribution or installer.**

The current work is focused on exploring and integrating:

| Area | Project / tool | Status |
|---|---|---|
| Shell experience | Shelled | Integration experiment |
| Tiling and workspaces | Komorebi | Installed; configuration in progress |
| Status bar | YASB | Installed; configuration in progress |
| Terminal | WezTerm | Integration target |
| Linux environment | WSL2 | Part of the planned environment |
| Containers | Docker | Part of the planned environment |
| Package management | Scoop, WinGet, Chocolatey | Tooling under evaluation |
| Runtime management | mise | Tooling under evaluation |
| Developer toolchains | Bun, Node.js, Rust, Go, C/C++ | Planned portable toolchain coverage |

This table describes the current exploration, not a promise that every integration is complete or supported.

See the [roadmap](docs/roadmap.md) for milestones, deliverables, and task tracking. Each milestone links to its GitHub tracking issue.

## Design direction

MooriShell's visual identity draws from Moroccan architecture and geometric craft:

- Dark, translucent surfaces and compact panels.
- Keyboard-driven navigation and tiling.
- Restrained Morocco red, desert sand, Atlantic blue and zellige green.
- Geometric patterns and architectural forms used as subtle design elements.

The design should feel like a modern desktop engineering project, not a themed Windows imitation.

## Repository layout

The repository is being organized around project-owned configuration and automation:

- `branding/` — visual identity, logos and design tokens.
- `configs/` — MooriShell-owned configurations for integrated tools.
- `docs/` — roadmap, architecture, setup, usage and troubleshooting.
- `scripts/` - installation, setup, validation and maintenance automation.
- `toolchain/` - developer toolchain definitions and environment setup.
- `Makefile` and `scripts/orchestrate.ts` - developer task orchestration using
  GNU Make, Bun, and the tools that own each build/test task.

Directories will be added as their contents become useful.

## Principles

1. **Respect upstream projects.** Prefer configuring and integrating existing tools over forking or duplicating them.
2. **Keep boundaries clear.** Document what belongs to MooriShell and what belongs to an upstream dependency.
3. **Make changes reproducible.** Prefer documented configuration and repeatable scripts over undocumented manual state.
4. **Be transparent.** Mark experimental, planned and supported functionality accurately.
5. **Protect the host.** Setup scripts should explain changes, avoid destructive defaults and provide recovery guidance where practical.

## Getting started

There is no supported one-command installation yet. The project is still defining its architecture and configuration layout.

For now, follow the upstream installation instructions for each tool. MooriShell-specific setup instructions will be documented here as they become reproducible.

For repository development tasks, see [the orchestration guide](docs/development/orchestration.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the current contribution expectations.

## Licensing

Original MooriShell materials in this repository are licensed under the [MIT License](LICENSE).

Third-party applications, dependencies, assets, and other upstream materials remain governed by their respective licenses and terms. The MooriShell license does not relicense those projects.
