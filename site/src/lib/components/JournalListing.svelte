<script lang="ts">
  import type { ArticleMetadata } from "#lib/content/journal";
  let { articles }: { articles: ArticleMetadata[] } = $props();
  let query = $state("");
  let activeCategory = $state("All dispatches");
  const categories = [
    "All dispatches",
    "01 — Field Notes",
    "02 — Desktop Engineering",
    "03 — The Toolchain",
    "04 — Linux on Windows",
    "05 — Architecture & Design",
    "06 — Moroccan Design",
    "07 — Open Source",
  ];
  let filtered = $derived(
    articles.filter((article) => {
      const matchesCategory =
        activeCategory === "All dispatches" ||
        article.category === activeCategory;
      const searchText =
        `${article.title} ${article.description} ${article.category} ${article.tags.join(" ")}`.toLowerCase();
      return matchesCategory && searchText.includes(query.toLowerCase().trim());
    }),
  );
</script>

<main class="journal-page section-wrap" id="main-content">
  <div class="section-kicker mono">
    <span>PUBLICATION / 001</span><span>MOORISHELL JOURNAL</span><span>—</span>
  </div>
  <header class="journal-hero">
    <div>
      <p class="mono journal-overline">
        FIELD NOTES FROM AN OPEN DESKTOP EXPERIMENT
      </p>
      <h1>Thinking at<br /><em>the edges.</em></h1>
    </div>
    <p>
      A technical journal on desktop engineering, toolchains, Linux on Windows,
      and the choices behind a modular workspace.
    </p>
  </header>
  {#if articles.find((article) => article.featured)}
    {@const featured = articles.find((article) => article.featured)!}
    <a class="featured-article" href="/journal/{featured.slug}">
      <div class="featured-index mono">
        <span>FEATURED DISPATCH</span><span>NO. 001</span>
      </div>
      <div class="featured-content">
        <span class="mono featured-meta">
          {featured.category.toUpperCase()} &nbsp;·&nbsp; {featured.date.replaceAll(
            "-",
            ".",
          )}
        </span>
        <h2>{featured.title}</h2>
        <p>{featured.description}</p>
        <span class="featured-link mono">
          READ THE DISPATCH <span aria-hidden="true">↗</span>
        </span>
      </div>
      <div class="featured-glyph" aria-hidden="true">✳</div>
    </a>
  {/if}
  <div class="journal-controls">
    <label class="search-field">
      <span class="sr-only">Search journal dispatches</span><span
        aria-hidden="true"
      >
        ⌕
      </span><input
        type="search"
        bind:value={query}
        placeholder="Search dispatches, topics, tags…"
      />
    </label>
    <div class="category-list" aria-label="Filter articles by category">
      {#each categories as category (category)}
        <button
          class:active={activeCategory === category}
          aria-pressed={activeCategory === category}
          onclick={() => (activeCategory = category)}
        >
          {category}
        </button>
      {/each}
    </div>
    <p class="mono result-count" aria-live="polite">
      {filtered.length.toString().padStart(2, "0")} DISPATCHES
    </p>
  </div>
  <div class="journal-results">
    {#each filtered as article, index (article.slug)}
      <a class="journal-card" href="/journal/{article.slug}">
        <span class="journal-card-index mono">
          {(index + 1).toString().padStart(2, "0")}
        </span>
        <div>
          <span class="mono journal-card-meta">
            {article.category.toUpperCase()} &nbsp;·&nbsp; {article.date.replaceAll(
              "-",
              ".",
            )}
          </span>
          <h2>{article.title}</h2>
          <p>{article.description}</p>
          <div class="tag-list">
            {#each article.tags as tag (tag)}<span>{tag}</span>{/each}
          </div>
        </div>
        <span class="journal-card-arrow" aria-hidden="true">↗</span>
      </a>
    {:else}
      <div class="empty-results">
        <p>No dispatches match that search.</p>
        <button
          onclick={() => {
            query = "";
            activeCategory = "All dispatches";
          }}
        >
          Clear filters
        </button>
      </div>
    {/each}
  </div>
  <p class="journal-disclaimer mono">
    EARLY EXPERIMENT · NOT A STABLE DISTRIBUTION · <a
      href="https://github.com/openanaffa/moorishell"
    >
      VIEW THE SOURCE ↗
    </a>
  </p>
</main>

<style>
  .journal-page {
    padding-block: clamp(4rem, 8vw, 7.5rem);
  }
  .journal-hero {
    display: flex;
    align-items: end;
    justify-content: space-between;
    gap: 3rem;
    margin: 3rem 0 4rem;
  }
  .journal-overline,
  .featured-meta,
  .featured-index,
  .featured-link,
  .search-field,
  .category-list button,
  .result-count,
  .journal-card-index,
  .journal-card-meta,
  .tag-list,
  .journal-disclaimer {
    font-family: var(--font-mono);
  }
  .journal-overline {
    margin-bottom: 1.2rem;
    color: #879398;
    font-size: 0.56rem;
    letter-spacing: 0.13em;
  }
  h1 {
    margin: 0;
    font: 500 clamp(4rem, 9vw, 8.6rem)/0.9 var(--font-display);
    letter-spacing: -0.085em;
  }
  h1 em {
    color: var(--sand);
    font-style: normal;
  }
  .journal-hero > p {
    max-width: 340px;
    margin: 0 0 0.4rem;
    color: #aab4b7;
    font-size: 0.9rem;
    line-height: 1.8;
  }
  .featured-article {
    min-height: 265px;
    position: relative;
    display: grid;
    grid-template-columns: 1fr 1.25fr;
    align-items: center;
    overflow: hidden;
    padding: 1.5rem 2rem;
    border: 1px solid #3d4a50;
    background: linear-gradient(112deg, #18242a 0%, #11191e 72%);
  }
  .featured-index {
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    color: #819096;
    font-size: 0.53rem;
    letter-spacing: 0.12em;
  }
  .featured-index span:first-child {
    color: var(--sand);
  }
  .featured-content {
    position: relative;
    z-index: 1;
    max-width: 540px;
    padding: 1.3rem 0;
  }
  .featured-meta {
    color: #89a8b2;
    font-size: 0.51rem;
    letter-spacing: 0.08em;
  }
  .featured-content h2 {
    max-width: 500px;
    margin: 1rem 0 0.6rem;
    font: 500 clamp(1.6rem, 3.6vw, 3.1rem)/1.04 var(--font-display);
    letter-spacing: -0.06em;
  }
  .featured-content p {
    max-width: 450px;
    margin-bottom: 1.3rem;
    color: #aab4b7;
    font-size: 0.8rem;
    line-height: 1.7;
  }
  .featured-link {
    color: var(--sand);
    font-size: 0.53rem;
    letter-spacing: 0.08em;
  }
  .featured-glyph {
    position: absolute;
    right: 2.5rem;
    bottom: -6rem;
    color: rgba(240, 221, 169, 0.08);
    font-size: 20rem;
    line-height: 1;
  }
  .journal-controls {
    margin-top: 4rem;
  }
  .search-field {
    height: 48px;
    display: flex;
    align-items: center;
    gap: 0.8rem;
    max-width: 550px;
    padding: 0 1rem;
    border: 1px solid #354249;
    color: var(--sand);
  }
  .search-field input {
    width: 100%;
    border: 0;
    outline: 0;
    background: transparent;
    color: var(--silver);
    font-size: 0.74rem;
  }
  .search-field input::placeholder {
    color: #78868c;
  }
  .category-list {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    margin-top: 1.3rem;
  }
  .category-list button {
    min-height: 34px;
    padding: 0.45rem 0.7rem;
    border: 1px solid #344148;
    background: transparent;
    color: #9ba7ab;
    cursor: pointer;
    font-size: 0.51rem;
    letter-spacing: 0.02em;
    transition:
      border-color 0.2s ease,
      color 0.2s ease,
      background 0.2s ease;
  }
  .category-list button:hover {
    border-color: #89969b;
    color: var(--silver);
  }
  .category-list button.active {
    border-color: var(--sand);
    background: rgba(240, 221, 169, 0.08);
    color: var(--sand);
  }
  .result-count {
    margin: 1.4rem 0 0.6rem;
    color: #758389;
    font-size: 0.49rem;
    letter-spacing: 0.12em;
  }
  .journal-results {
    border-top: 1px solid var(--line-light);
  }
  .journal-card {
    display: grid;
    grid-template-columns: 55px 1fr 24px;
    gap: 1rem;
    padding: 1.6rem 0.4rem;
    border-bottom: 1px solid var(--line);
    transition:
      background 0.2s ease,
      padding 0.2s ease;
  }
  .journal-card:hover {
    padding-inline: 0.8rem;
    background: rgba(255, 255, 255, 0.02);
  }
  .journal-card-index {
    padding-top: 0.12rem;
    color: var(--red);
    font-size: 0.58rem;
  }
  .journal-card-meta {
    color: #819096;
    font-size: 0.5rem;
    letter-spacing: 0.08em;
  }
  .journal-card h2 {
    margin: 0.65rem 0 0.35rem;
    font: 500 clamp(1.05rem, 2.4vw, 1.5rem) var(--font-display);
    letter-spacing: -0.04em;
  }
  .journal-card p {
    margin: 0;
    color: #9da8ac;
    font-size: 0.75rem;
    line-height: 1.7;
  }
  .journal-card-arrow {
    color: var(--sand);
    text-align: right;
  }
  .tag-list {
    display: flex;
    gap: 0.45rem;
    flex-wrap: wrap;
    margin-top: 0.9rem;
  }
  .tag-list span {
    padding: 0.25rem 0.4rem;
    border: 1px solid #2d393f;
    color: #89969b;
    font-size: 0.46rem;
  }
  .empty-results {
    padding: 3rem 1rem;
    text-align: center;
    color: #9da8ac;
  }
  .empty-results button {
    padding: 0.5rem 0.7rem;
    border: 1px solid var(--line-light);
    background: transparent;
    color: var(--sand);
    cursor: pointer;
  }
  .journal-disclaimer {
    margin-top: 2rem;
    color: #758389;
    font-size: 0.49rem;
    letter-spacing: 0.08em;
  }
  .journal-disclaimer a {
    color: var(--sand);
  }
  @media (max-width: 700px) {
    .journal-hero {
      display: block;
      margin: 2.5rem 0 3rem;
    }
    .journal-hero > p {
      margin-top: 1.3rem;
    }
    .featured-article {
      min-height: 300px;
      grid-template-columns: 1fr;
      padding: 1rem 1.2rem;
    }
    .featured-index {
      flex-direction: row;
      height: auto;
    }
    .featured-content {
      padding: 3rem 0 0.5rem;
    }
    .featured-glyph {
      right: -0.3rem;
      bottom: -3rem;
      font-size: 13rem;
    }
    .journal-card {
      grid-template-columns: 30px 1fr 18px;
      gap: 0.55rem;
    }
    .journal-disclaimer {
      line-height: 1.8;
    }
  }
</style>
