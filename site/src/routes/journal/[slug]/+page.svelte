<script lang="ts">
  import { onMount } from "svelte";
  import { articles } from "#lib/content/journal";
  import type { PageProps } from "./$types";

  let { data }: PageProps = $props();
  let selected = $derived(
    articles.find((article) => article.metadata.slug === data.slug),
  );
  let metadata = $derived(selected?.metadata);
  let toc = $state<{ id: string; title: string; level: number }[]>([]);
  let readingMinutes = $state(1);
  let articleIndex = $derived(
    articles.findIndex((article) => article.metadata.slug === data.slug),
  );
  let previous = $derived(
    articleIndex > 0 ? articles[articleIndex - 1] : undefined,
  );
  let next = $derived(
    articleIndex >= 0 && articleIndex < articles.length - 1
      ? articles[articleIndex + 1]
      : undefined,
  );

  onMount(() => {
    const content = document.querySelector(".article-body");
    if (!content) return;
    const headings = Array.from(content.querySelectorAll("h2, h3"));
    toc = headings.map((heading, index) => {
      const title = heading.textContent?.trim() ?? "";
      const id =
        heading.id ||
        `${title.toLowerCase().replace(/[^a-z0-9]+/g, "-")}-${index + 1}`;
      heading.id = id;
      return { id, title, level: heading.tagName === "H3" ? 3 : 2 };
    });
    const words =
      content.textContent?.trim().split(/\s+/).filter(Boolean).length ?? 0;
    readingMinutes = Math.max(1, Math.ceil(words / 220));
  });
</script>

<svelte:head>
  {#if metadata}
    <title>{metadata.title} — MooriShell Journal</title>
    <meta name="description" content={metadata.description} />
    <meta property="og:type" content="article" />
    <meta property="og:title" content={metadata.title} />
    <meta property="og:description" content={metadata.description} />
    <meta property="article:published_time" content={metadata.date} />
    <meta name="twitter:card" content="summary" />
    <link
      rel="canonical"
      href="https://m7r.is-cool.dev/moorishell/journal/{metadata.slug}"
    />
  {/if}
</svelte:head>

{#if selected}
  {@const metadata = selected.metadata}
  {@const ArticleContent = selected.component}
  <main id="main-content" class="article-page section-wrap">
    <div class="article-breadcrumb mono">
      <a href="/journal">JOURNAL</a><span>/</span><span>
        {metadata.category.toUpperCase()}
      </span>
    </div>
    <header class="article-header">
      <p class="mono article-date">
        {metadata.date.replaceAll("-", ".")} &nbsp;·&nbsp; {metadata.author}
      </p>
      <h1>{metadata.title}</h1>
      <p class="article-deck">{metadata.description}</p>
      <div class="article-tags">
        {#each metadata.tags as tag (tag)}<span>{tag}</span>{/each}
      </div>
      <div class="article-reading mono">
        <span>{readingMinutes} MIN READ</span><span>
          UPDATED {metadata.updatedAt.replaceAll("-", ".")}
        </span>
      </div>
    </header>
    <div class="article-layout">
      <aside class="article-toc" aria-label="Article contents">
        <p class="mono">IN THIS DISPATCH</p>
        <nav>
          {#each toc as item (item.id)}
            <a class:toc-sub={item.level === 3} href="#{item.id}">
              {item.title}
            </a>
          {/each}
        </nav>
      </aside>
      <article class="article-body"><ArticleContent /></article>
    </div>
    <nav class="article-pagination" aria-label="More journal dispatches">
      {#if previous}<a
          class="article-neighbor"
          href="/journal/{previous.metadata.slug}"
        >
          <span class="mono">← PREVIOUS DISPATCH</span><strong>
            {previous.metadata.title}
          </strong>
        </a>{:else}<span></span>{/if}
      {#if next}<a
          class="article-neighbor next-neighbor"
          href="/journal/{next.metadata.slug}"
        >
          <span class="mono">NEXT DISPATCH →</span><strong>
            {next.metadata.title}
          </strong>
        </a>{/if}
    </nav>
    <section class="related-block">
      <p class="mono">KEEP EXPLORING</p>
      <a href="/journal">
        All MooriShell Journal dispatches <span aria-hidden="true">↗</span>
      </a>
    </section>
  </main>
{:else}
  <main id="main-content" class="article-page section-wrap">
    <p>Dispatch not found.</p>
    <a href="/journal">Return to the journal</a>
  </main>
{/if}

<style>
  .article-page {
    padding-block: 3.5rem 7rem;
  }
  .article-breadcrumb,
  .article-date,
  .article-tags,
  .article-reading,
  .article-toc > p,
  .article-pagination .mono,
  .related-block > p {
    font-family: var(--font-mono);
  }
  .article-breadcrumb {
    display: flex;
    gap: 0.7rem;
    color: #849197;
    font-size: 0.52rem;
    letter-spacing: 0.09em;
  }
  .article-breadcrumb a {
    color: var(--sand);
  }
  .article-header {
    width: min(100%, 850px);
    margin: 4rem auto 4.5rem;
    text-align: center;
  }
  .article-date {
    color: #8aa9b2;
    font-size: 0.54rem;
    letter-spacing: 0.1em;
  }
  .article-header h1 {
    margin: 1.3rem 0;
    font: 500 clamp(2.7rem, 7vw, 6rem)/0.98 var(--font-display);
    letter-spacing: -0.075em;
  }
  .article-deck {
    max-width: 650px;
    margin: 0 auto;
    color: #aab4b7;
    font-size: clamp(0.93rem, 1.6vw, 1.12rem);
    line-height: 1.75;
  }
  .article-tags {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 0.5rem;
    margin-top: 1.4rem;
  }
  .article-tags span {
    border: 1px solid #344148;
    padding: 0.3rem 0.5rem;
    color: #9aa6aa;
    font-size: 0.48rem;
  }
  .article-reading {
    display: flex;
    justify-content: center;
    gap: 1rem;
    margin-top: 1.4rem;
    color: #78868c;
    font-size: 0.5rem;
    letter-spacing: 0.08em;
  }
  .article-layout {
    display: grid;
    grid-template-columns: 210px minmax(0, 700px);
    justify-content: center;
    gap: clamp(2rem, 6vw, 6rem);
    align-items: start;
  }
  .article-toc {
    position: sticky;
    top: 105px;
    padding: 0.5rem 0 0;
  }
  .article-toc > p,
  .related-block > p {
    margin-bottom: 1rem;
    color: var(--sand);
    font-size: 0.51rem;
    letter-spacing: 0.1em;
  }
  .article-toc nav {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    border-left: 1px solid #344148;
    padding-left: 0.9rem;
  }
  .article-toc nav a {
    color: #8d999e;
    font-size: 0.65rem;
    line-height: 1.55;
    transition: color 0.2s ease;
  }
  .article-toc nav a:hover {
    color: var(--sand);
  }
  .article-toc nav a.toc-sub {
    padding-left: 0.6rem;
    font-size: 0.6rem;
  }
  .article-body {
    min-width: 0;
    color: #c4ccce;
    font-size: 0.94rem;
    line-height: 1.9;
  }
  .article-body :global(p) {
    margin: 0 0 1.3rem;
  }
  .article-body :global(h2) {
    margin: 3rem 0 1rem;
    color: var(--silver);
    font: 500 1.8rem/1.2 var(--font-display);
    letter-spacing: -0.045em;
    scroll-margin-top: 100px;
  }
  .article-body :global(h3) {
    margin: 2rem 0 0.8rem;
    font: 500 1.25rem var(--font-display);
    scroll-margin-top: 100px;
  }
  .article-body :global(a) {
    color: var(--sand);
    text-decoration: underline;
    text-decoration-color: rgba(240, 221, 169, 0.4);
    text-underline-offset: 3px;
  }
  .article-body :global(blockquote) {
    margin: 2rem 0;
    padding: 0.3rem 0 0.3rem 1.2rem;
    border-left: 2px solid var(--red);
    color: var(--sand);
    font: 500 1.15rem/1.6 var(--font-display);
  }
  .article-body :global(pre) {
    overflow-x: auto;
    margin: 1.8rem 0;
    padding: 1.1rem 1.2rem;
    border: 1px solid #2d3b41;
    background: #0d1519;
    color: #d0d7d9;
    font: 0.73rem/1.8 var(--font-mono);
  }
  .article-body :global(code:not(pre code)) {
    padding: 0.15rem 0.35rem;
    border: 1px solid #2d3b41;
    background: #182329;
    color: var(--sand);
    font: 0.82em var(--font-mono);
  }
  .article-body :global(ul),
  .article-body :global(ol) {
    padding-left: 1.3rem;
  }
  .article-body :global(li) {
    margin: 0.45rem 0;
  }
  .article-body :global(.shiki) {
    border-radius: 0;
  }
  .article-pagination {
    display: flex;
    justify-content: space-between;
    gap: 2rem;
    max-width: 910px;
    margin: 4rem auto 0;
    padding-top: 1.3rem;
    border-top: 1px solid var(--line);
  }
  .article-neighbor {
    display: flex;
    flex-direction: column;
    gap: 0.7rem;
    max-width: 45%;
  }
  .article-pagination .mono {
    color: #819096;
    font-size: 0.48rem;
    letter-spacing: 0.1em;
  }
  .article-neighbor strong {
    font: 500 0.9rem var(--font-display);
  }
  .next-neighbor {
    text-align: right;
  }
  .related-block {
    max-width: 910px;
    margin: 2rem auto 0;
    padding: 1.3rem 0;
    border-top: 1px solid var(--line);
  }
  .related-block a {
    color: var(--sand);
    font: 0.72rem var(--font-mono);
  }
  @media (max-width: 800px) {
    .article-layout {
      grid-template-columns: 1fr;
    }
    .article-toc {
      position: static;
      order: 1;
      padding: 1rem;
      border: 1px solid var(--line);
      background: #141e23;
    }
    .article-toc nav {
      display: grid;
      grid-template-columns: 1fr 1fr;
    }
    .article-toc nav a.toc-sub {
      padding-left: 0;
    }
    .article-body {
      order: 2;
    }
    .article-header {
      margin: 3rem auto;
    }
    .article-pagination,
    .related-block {
      margin-top: 3rem;
    }
  }
  @media (max-width: 520px) {
    .article-reading {
      flex-direction: column;
      gap: 0.4rem;
    }
    .article-body {
      font-size: 0.88rem;
    }
    .article-toc nav {
      grid-template-columns: 1fr;
    }
  }
</style>
