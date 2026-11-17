<script lang="ts">
  let menuOpen = $state(false);

  const links = [
    { label: "Overview", href: "/#overview" },
    { label: "Philosophy", href: "/#philosophy" },
    { label: "Architecture", href: "/#architecture" },
    { label: "Journal", href: "/journal" },
    {
      label: "Documentation",
      href: "https://github.com/openanaffa/moorishell/tree/main/docs",
    },
    {
      label: "GitHub",
      href: "https://github.com/openanaffa/moorishell",
      external: true,
    },
  ];
</script>

<header class="site-header">
  <div class="header-inner">
    <a class="brand" href="/" aria-label="MooriShell home">
      <svg class="brand-mark" viewBox="0 0 40 40" aria-hidden="true">
        <path
          d="M20 2.5 25 11l9.8-1.2-1.2 9.8 8.5 5-8.5 5 1.2 9.8L25 38l-5 8.5-5-8.5-9.8 1.2 1.2-9.8-8.5-5 8.5-5-1.2-9.8L15 11z"
          transform="translate(3 0) scale(.85)"
          fill="none"
          stroke="currentColor"
          stroke-width="1.6"
        />
        <path
          d="M13 27V15l7 8 7-8v12"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="square"
          stroke-linejoin="miter"
        />
      </svg>
      <span>Moori<span class="brand-light">Shell</span></span>
    </a>
    <button
      class="menu-toggle"
      aria-label={menuOpen ? "Close navigation menu" : "Open navigation menu"}
      aria-expanded={menuOpen}
      aria-controls="primary-navigation"
      onclick={() => (menuOpen = !menuOpen)}
    >
      <span></span><span></span>
    </button>
    <nav
      id="primary-navigation"
      class:open={menuOpen}
      aria-label="Primary navigation"
    >
      {#each links as link (link.label)}
        <a
          href={link.href}
          target={link.external ? "_blank" : undefined}
          rel={link.external ? "noreferrer" : undefined}
          onclick={() => (menuOpen = false)}
        >
          {link.label}
        </a>
      {/each}
    </nav>
  </div>
</header>
