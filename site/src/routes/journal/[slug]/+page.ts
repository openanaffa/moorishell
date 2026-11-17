import { error } from "@sveltejs/kit";
import type { PageLoad } from "./$types";
import { articleMetadata } from "#lib/content/journal";

export const load: PageLoad = ({ params }) => {
  if (!articleMetadata.some((article) => article.slug === params.slug))
    error(404, "Dispatch not found");
  return { slug: params.slug };
};
