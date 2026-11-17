# MooriShell website design system

## Direction

Modern Moorish computing: a restrained editorial interface where geometric craft, desktop engineering, and open-source documentation share one visual language. Use architectural framing and precise interaction—not ornamental motifs detached from product context.

## Color tokens

| Token | Value | Use |
| --- | --- | --- |
| Atlas Night | `#11191E` | Primary canvas |
| Morocco Red | `#D71920` | Status and primary action accent |
| Desert Sand | `#F0DDA9` | Editorial emphasis and focus |
| Atlantic Blue | `#347A92` | Technical states |
| Zellige Green | `#394F44` | Supporting accent |
| Silver | `#D8DCE0` | Primary typography |

Tokens are defined in `src/routes/layout.css` and the Tailwind v4 `@theme` block.

## Type

- Space Grotesk: headlines and compact display labels.
- Manrope: body and editorial reading.
- IBM Plex Mono: status, metadata, code, and navigation.

## Layout and interaction

- Editorial grid with asymmetry on wide screens; single-column flow on narrow screens.
- Flexbox for toolbars, navigation, and aligned content; grid for multi-column editorial structures.
- Fine borders and dark surfaces establish hierarchy. Zellige geometry appears as structural pattern, not a wallpaper texture.
- Scroll reveals are progressive enhancement via GSAP and ScrollTrigger. `prefers-reduced-motion` disables them and CSS transitions are minimized.
- Interactive architecture layers use buttons with `aria-pressed`; the mobile navigation exposes `aria-expanded` and supports keyboard focus.

## Editorial integrity

The desktop illustration is a conceptual composition, not a product screenshot. Project maturity, integration status, and roadmap labels follow the repository README, ADRs, and `docs/roadmap.md`. Never use unverified metrics, compatibility claims, testimonials, or upstream assets as MooriShell-owned material.
