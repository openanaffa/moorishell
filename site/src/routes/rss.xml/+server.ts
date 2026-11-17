import { articleMetadata } from "#lib/content/journal";
import type { RequestHandler } from "./$types";

const origin = "https://m7r.is-cool.dev/moorishell";
const escapeXml = (value: string) =>
  value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&apos;");

export const prerender = true;

export const GET: RequestHandler = () => {
  const items = articleMetadata
    .map(
      (article) => `
		<item>
			<title>${escapeXml(article.title)}</title>
			<link>${origin}/journal/${article.slug}</link>
			<guid isPermaLink="true">${origin}/journal/${article.slug}</guid>
			<description>${escapeXml(article.description)}</description>
			<pubDate>${new Date(`${article.date}T12:00:00Z`).toUTCString()}</pubDate>
			<category>${escapeXml(article.category)}</category>
		</item>`,
    )
    .join("");
  const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<rss version="2.0"><channel><title>MooriShell Journal</title><link>${origin}/journal</link><description>Technical dispatches from an open desktop experiment.</description><language>en</language>${items}\n</channel></rss>`;
  return new Response(xml, {
    headers: {
      "content-type": "application/rss+xml; charset=utf-8",
      "cache-control": "public, max-age=3600",
    },
  });
};
