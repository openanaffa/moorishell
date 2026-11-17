<script lang="ts">
  const layers = [
    {
      id: "host",
      number: "00",
      label: "Windows host",
      detail:
        "Windows remains the operating system. MooriShell does not replace Explorer or modify Winlogon.",
    },
    {
      id: "desktop",
      number: "01",
      label: "Desktop layer",
      detail:
        "Shelled, Komorebi, YASB, and WezTerm are distinct upstream tools. Core integration work is experimental and in progress.",
    },
    {
      id: "tools",
      number: "02",
      label: "Toolchain",
      detail:
        "Scoop, WinGet, and Chocolatey are evaluated under a one-source-per-package policy. mise and language runtimes are planned profile work.",
    },
    {
      id: "workspace",
      number: "03",
      label: "Workspaces",
      detail:
        "WSL2 and Docker are optional directions. They are not required for the core desktop and are not represented as a validated setup.",
    },
  ];
  let active = $state("desktop");
  let activeLayer = $derived(
    layers.find((layer) => layer.id === active) ?? layers[1],
  );
</script>

<section
  class="architecture-section section-wrap"
  id="architecture"
  aria-labelledby="architecture-title"
>
  <div class="section-kicker mono">
    <span>03</span><span>THE ARCHITECTURE</span><span>—</span>
  </div>
  <div class="architecture-heading">
    <h2 class="section-heading reveal" id="architecture-title">
      A stack with<br /><em>clear edges.</em>
    </h2>
    <p class="reveal">
      A map of the project&apos;s direction, not a compatibility promise. Select
      a layer to see its current role.
    </p>
  </div>
  <div class="architecture-grid reveal">
    <div
      class="architecture-layers"
      role="group"
      aria-label="Select architecture layer"
    >
      {#each layers as layer (layer.id)}
        <button
          class="architecture-layer"
          class:active={active === layer.id}
          aria-pressed={active === layer.id}
          onclick={() => (active = layer.id)}
        >
          <span class="layer-index mono">{layer.number}</span><span>
            {layer.label}
          </span><span class="layer-arrow" aria-hidden="true">↗</span>
        </button>
      {/each}
    </div>
    <div class="architecture-detail" aria-live="polite">
      <div class="diagram-orbit" aria-hidden="true">
        <div class="orbit orbit-one"></div>
        <div class="orbit orbit-two"></div>
        <div class="orbit-center">M</div>
        <span class="orbit-node node-one">WIN</span><span
          class="orbit-node node-two"
        >
          LINUX
        </span><span class="orbit-node node-three">DEV</span>
      </div>
      <span class="mono detail-label">
        LAYER {activeLayer.number} / {activeLayer.label.toUpperCase()}
      </span>
      <p>{activeLayer.detail}</p>
      <a
        href="https://github.com/openanaffa/moorishell/blob/main/docs/architecture/overview.md"
        target="_blank"
        rel="noreferrer"
      >
        Read the architecture overview <span aria-hidden="true">↗</span>
      </a>
    </div>
  </div>
  <div class="ecosystem-note mono">
    <span>UNDER EVALUATION</span><span>Scoop · WinGet · Chocolatey</span><span>
      PLANNED
    </span><span>mise · Bun · Node · Rust · Go · C/C++ · WSL2 · Docker</span>
  </div>
</section>
