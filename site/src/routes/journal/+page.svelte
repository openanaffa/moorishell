<script lang="ts">
  import JournalListing from "#lib/components/JournalListing.svelte";
  import { articleMetadata } from "#lib/content/journal";
</script>

<svelte:head>
  <title>MooriShell Journal — Notes from the workbench</title>
  <meta
    name="description"
    content="Technical field notes on desktop engineering, toolchains, and building MooriShell in the open."
  />
  <meta
    property="og:title"
    content="MooriShell Journal — Notes from the workbench"
  />
  <meta
    property="og:description"
    content="Technical field notes on a Windows-native desktop experiment."
  />
  <link
    rel="alternate"
    type="application/rss+xml"
    title="MooriShell Journal"
    href="/rss.xml"
  />
</svelte:head>

<JournalListing articles={articleMetadata} />
