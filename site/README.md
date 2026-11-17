# MooriShell website

The editorial website and MooriShell Journal live in this directory so they can be developed independently from the Windows configuration and provisioning tools in the repository root.

## Project status

The site describes the project as an early experiment. It does not present MooriShell as an operating system, installer, stable distribution, or validated compatibility matrix. The desktop illustration is conceptual; the repository currently has no product screenshots to use.

Project facts and milestone states follow the root `README.md`, `docs/architecture/`, and `docs/roadmap.md`. When those sources change, update the site to match. Keep repository links canonical to `https://github.com/openanaffa/moorishell`.

## Stack

- SvelteKit 3, Svelte 5, and TypeScript
- Bun and the checked-in `bun.lock`
- Tailwind CSS 4 with tokens in `src/routes/layout.css`
- MDsveX content with Shiki-based code highlighting
- GSAP ScrollTrigger, respecting `prefers-reduced-motion`

## Local development

From this directory, run `bun install` and `bun run dev`. Quality checks are available as `bun run check`, `bun run lint`, `bun run format:check`, and `bun run build` (or together with `bun run check:all`).

Articles live in `src/lib/content/journal/` as MDsveX files with frontmatter. Keep article slugs unique, set `draft: true` until an article is ready, and review the RSS and sitemap endpoints when changing public routes.

See [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) for visual tokens, motion behavior, and editorial integrity rules.
