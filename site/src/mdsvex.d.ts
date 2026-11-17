declare module "*.svx" {
  const component: import("svelte").Component;
  export const metadata: Record<string, unknown>;
  export default component;
}

declare module "*.md" {
  const component: import("svelte").Component;
  export const metadata: Record<string, unknown>;
  export default component;
}
