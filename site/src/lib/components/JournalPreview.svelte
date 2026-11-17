<script lang="ts">
  const articles = [
    {
      category: "FIELD NOTES",
      date: "2026.11.17",
      title: "A desktop experiment, not another operating system",
      slug: "a-desktop-experiment-not-another-operating-system",
      read: "4 MIN READ",
    },
    {
      category: "ARCHITECTURE & DESIGN",
      date: "2026.11.17",
      title: "Where MooriShell ends and upstream begins",
      slug: "where-moorishell-ends-and-upstream-begins",
      read: "5 MIN READ",
    },
    {
      category: "THE TOOLCHAIN",
      date: "2026.11.17",
      title: "One package, one owner",
      slug: "one-package-one-owner",
      read: "4 MIN READ",
    },
  ];
</script>

<section
  class="journal-preview section-wrap"
  id="journal"
  aria-labelledby="journal-title"
>
  <div class="section-kicker mono">
    <span>05</span><span>MOORISHELL JOURNAL</span><span>—</span>
  </div>
  <div class="journal-heading">
    <h2 class="section-heading reveal" id="journal-title">
      Notes from<br /><em>the workbench.</em>
    </h2>
    <a class="text-link reveal" href="/journal">
      All dispatches <span aria-hidden="true">↗</span>
    </a>
  </div>
  <div class="preview-list">
    {#each articles as article, i (article.slug)}
      <a class="preview-row reveal" href="/journal/{article.slug}">
        <span class="preview-number mono">0{i + 1}</span><span
          class="preview-meta mono"
        >
          {article.category} <i>·</i>
          {article.date}
        </span><strong>{article.title}</strong><span class="preview-read mono">
          {article.read}
        </span><span class="preview-arrow" aria-hidden="true">↗</span>
      </a>
    {/each}
  </div>
</section>
