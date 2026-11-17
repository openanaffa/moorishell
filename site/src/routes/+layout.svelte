<script lang="ts">
  import "./layout.css";
  import SiteHeader from "#lib/components/SiteHeader.svelte";
  import SiteFooter from "#lib/components/SiteFooter.svelte";
  import type { LayoutProps } from "./$types";

  let { children }: LayoutProps = $props();
</script>

<svelte:head>
  <title>MooriShell — Your workspace. Your rules.</title>
  <meta
    name="description"
    content="A Moorish workspace for modern makers. Windows-native. Linux-inspired. Open by design."
  />
  <meta name="theme-color" content="#11191e" />
  <meta property="og:site_name" content="MooriShell" />
  <meta property="og:type" content="website" />
  <meta
    property="og:title"
    content="MooriShell — Your workspace. Your rules."
  />
  <meta
    property="og:description"
    content="An open-source desktop experience exploring a better way to work on Windows."
  />
  <meta name="twitter:card" content="summary_large_image" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link
    rel="preconnect"
    href="https://fonts.gstatic.com"
    crossorigin="anonymous"
  />
  <link
    href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Manrope:wght@400;500;600;700&family=Space+Grotesk:wght@400;500;600;700&display=swap"
    rel="stylesheet"
  />
</svelte:head>

<a class="skip-link" href="#main-content">Skip to content</a>
<SiteHeader />
{@render children()}
<SiteFooter />
