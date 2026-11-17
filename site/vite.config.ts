import adapter from "@sveltejs/adapter-vercel";
import { vitePreprocess } from "@sveltejs/vite-plugin-svelte";
import { mdsvex } from "mdsvex";
import rehypePrettyCode from "rehype-pretty-code";
import tailwindcss from "@tailwindcss/vite";
import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [
    tailwindcss(),
    sveltekit({
      adapter: adapter(),
      extensions: [".svelte", ".svx", ".md"],
      preprocess: [
        vitePreprocess(),
        mdsvex({
          extensions: [".svx", ".md"],
          rehypePlugins: [
            [rehypePrettyCode as never, { theme: "github-dark" } as never],
          ],
        }),
      ],
      compilerOptions: { runes: true },
    }),
  ],
});
