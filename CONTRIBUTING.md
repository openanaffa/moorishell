# Contributing to MooriShell

MooriShell is in an early experimental stage. Contributions should help make the Windows desktop experience more coherent, reproducible and maintainable.

## Before contributing

- Check the README, [roadmap](docs/roadmap.md), and existing issues before starting work.
- For substantial changes, open an issue or discussion first so the approach can be agreed.
- Keep pull requests focused and explain the problem they solve.
- Distinguish verified behavior from experiments and planned work.

## Configuration changes

When changing a configuration:

- Identify the upstream application and the version or release it targets, when known.
- Keep MooriShell-specific changes separate from upstream defaults.
- Document required dependencies and installation steps.
- Do not commit personal paths, credentials, tokens, private keys or machine-specific secrets.
- Include a validation or manual test procedure.

## Scripts

Scripts that modify the host must:

- Explain what they will change.
- Fail clearly when prerequisites are missing.
- Avoid destructive defaults.
- Check command exit codes.
- Provide recovery instructions for changes that are difficult to reverse.

## Pull requests

Include:

1. The problem and motivation.
2. A summary of the changes.
3. Dependencies or compatibility assumptions.
4. Validation performed and its result.
5. Screenshots for meaningful visual changes, where useful.

Do not claim a feature is complete unless it has been tested.

## Upstream projects and licensing

Do not copy or redistribute upstream source code, assets or binaries without checking the applicable license and attribution requirements. Prefer links to official upstream installation and documentation sources.

Original MooriShell materials are licensed under the MIT License. Contributions submitted to this repository are intended to be distributed under the same license. Third-party dependencies and assets remain under their own licenses.
