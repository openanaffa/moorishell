<script lang="ts">
  import { onMount } from "svelte";
  import HeroSection from "#lib/components/HeroSection.svelte";
  import PhilosophySection from "#lib/components/PhilosophySection.svelte";
  import WorkspaceSection from "#lib/components/WorkspaceSection.svelte";
  import ArchitectureSection from "#lib/components/ArchitectureSection.svelte";
  import PatternSection from "#lib/components/PatternSection.svelte";
  import RoadmapSection from "#lib/components/RoadmapSection.svelte";
  import JournalPreview from "#lib/components/JournalPreview.svelte";

  onMount(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    let cancelled = false;
    let context: { revert: () => void } | undefined;
    void Promise.all([import("gsap"), import("gsap/ScrollTrigger")]).then(
      ([{ gsap }, { ScrollTrigger }]) => {
        if (cancelled) return;
        gsap.registerPlugin(ScrollTrigger);
        context = gsap.context(() => {
          gsap.utils.toArray<HTMLElement>(".reveal").forEach((element) => {
            gsap.fromTo(
              element,
              { opacity: 0, y: 22 },
              {
                opacity: 1,
                y: 0,
                duration: 0.7,
                ease: "power2.out",
                scrollTrigger: {
                  trigger: element,
                  start: "top 88%",
                  once: true,
                },
              },
            );
          });
        });
      },
    );
    return () => {
      cancelled = true;
      context?.revert();
    };
  });
</script>

<main id="main-content">
  <HeroSection />
  <PhilosophySection />
  <WorkspaceSection />
  <ArchitectureSection />
  <PatternSection />
  <RoadmapSection />
  <JournalPreview />
  <section class="community-cta section-wrap" aria-labelledby="community-title">
    <div class="community-mark" aria-hidden="true">✳</div>
    <div>
      <span class="mono community-kicker">
        AN OPEN PROJECT · BUILT IN PUBLIC
      </span>
      <h2 id="community-title">A workspace is<br /><em>never finished.</em></h2>
      <p>
        Explore the source, follow the roadmap, or help shape what comes next.
      </p>
    </div>
    <div class="community-actions">
      <a
        class="button button-primary"
        href="https://github.com/openanaffa/moorishell"
        target="_blank"
        rel="noreferrer"
      >
        Explore the repository <span aria-hidden="true">↗</span>
      </a><a
        class="button button-quiet"
        href="https://github.com/openanaffa/moorishell/issues"
        target="_blank"
        rel="noreferrer"
      >
        Browse open issues <span aria-hidden="true">↗</span>
      </a>
    </div>
  </section>
</main>
