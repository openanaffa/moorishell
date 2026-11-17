import { articleMetadata } from "#lib/content/journal";
import type { RequestHandler } from "./$types";

const origin = "https://m7r.is-cool.dev/moorishell";

export const prerender = true;

export const GET: RequestHandler = () => {
  const pages = [
    { path: "", lastmod: "2026-11-17" },
    { path: "/journal", lastmod: "2026-11-17" },
    ...articleMetadata.map((article) => ({
      path: `/journal/${article.slug}`,
      lastmod: article.updatedAt,
    })),
  ];
  const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${pages.map((page) => `<url><loc>${origin}${page.path}</loc><lastmod>${page.lastmod}</lastmod></url>`).join("")}</urlset>`;
  return new Response(xml, {
    headers: {
      "content-type": "application/xml; charset=utf-8",
      "cache-control": "public, max-age=3600",
    },
  });
};
