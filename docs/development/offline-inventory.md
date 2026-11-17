# Offline source and toolchain inventory

**Observed:** 2026-11-17 on the current development machine. This is an
inventory, not a guarantee that every cache is complete or relocatable.

## Available local sources and artifacts

| Item | Location | Notes |
|---|---|---|
| MooriShell and upstream source clones | `F:\sources\moorishell`, `F:\sources\shelled`, `F:\sources\wezterm`, `F:\sources\komorebi`, `F:\sources\yasb` | MooriShell tracks the four integrations as submodules; `.gitmodules` uses canonical HTTPS URLs. Offline submodule initialization requires their Git objects to already exist locally. |
| Komorebi release | `F:\sources\releases\komorebi-0.1.41-x86_64-pc-windows-msvc.zip` and extracted `komorebi-0.1.41` | Previously checksum-verified during setup; re-check archive hash before redistribution or fresh use. |
| WezTerm release | `F:\sources\releases\WezTerm-windows-20240203-110809-5046fc22.zip` and extracted directory | SHA-256 sidecar is present; verify against it before use. |
| YASB Python environment | `F:\sources\yasb\.venv-py314` | Python 3.14 environment with dependencies installed; requires the matching Python runtime and wheel/cache set to recreate offline. |
| Rust toolchains | `C:\Program Files\Rust stable GNU 1.100\bin`; `C:\Program Files\Rust stable MSVC 1.100\bin` | Both installed locally; Cargo registry sources/cache are also available under the user profile and `E:\moorishell\Caches`. |
| Rust build output/cache | `E:\build-cache\cargo-home`, `E:\build-cache\rust-target`, `E:\build-cache\rust-target-wezterm` | Reusable machine-local caches; not repository content. |
| Auxiliary build toolchains | `E:\build-cache\toolchains\strawberry-perl`, `E:\build-cache\toolchains\winlibs` | Portable Perl and MinGW-w64 extraction trees; matching zip archives also exist in `E:\build-cache`. |
| Other language/package cache roots | `E:\moorishell\Caches\npm`, `E:\moorishell\Caches\cargo-registry` | Cache roots exist; package completeness and offline behavior have not yet been tested. |

## Zed

Zed `1.28.1` is installed. The user already has 48 installed extensions, including
PowerShell, TOML, C#, GitHub Actions, Dockerfile, Nix, Catppuccin, and JetBrains
New UI Icons. Project recommendations are in `.zed/extensions.json`; project
settings are in `.zed/settings.json`. JSON/JSONC, Markdown, and YAML support are
provided by Zed's built-in language support; no separate YAML extension is
recommended. Zed extensions themselves are cached in
`%LOCALAPPDATA%\Zed\extensions\installed`, but extension installation/update
and LSP server downloads may still need network access.

## Known gaps before claiming an offline build

- WezTerm and Komorebi source builds previously stopped on missing toolchain
  dependencies; the prebuilt releases are available but do not constitute
  reproducible source builds.
- No complete Scoop/WinGet/Chocolatey package cache inventory was established.
- Python wheel cache completeness and a clean offline YASB environment rebuild
  have not been verified.
- Git submodule fetch from canonical URLs needs network unless each object set is
  already present locally.
- Do not copy caches into Git. They may contain machine-specific or licensed
  artifacts; keep them in the external cache/source locations.
