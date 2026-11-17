import { articleMetadata } from "#lib/content/journal";

export const prerender = true;
export const entries = () => articleMetadata.map(({ slug }) => ({ slug }));
