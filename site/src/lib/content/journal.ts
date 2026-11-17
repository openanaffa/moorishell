import * as fieldNotes from "./journal/a-desktop-experiment-not-another-operating-system.svx";
import * as ownership from "./journal/where-moorishell-ends-and-upstream-begins.svx";
import * as packages from "./journal/one-package-one-owner.svx";

export type ArticleMetadata = {
  title: string;
  slug: string;
  description: string;
  date: string;
  updatedAt: string;
  author: string;
  category: string;
  tags: string[];
  coverImage: string;
  featured: boolean;
  draft: boolean;
};

const normalizeDate = (value: string) =>
  new Date(value).toISOString().slice(0, 10);

export const articles = [fieldNotes, ownership, packages]
  .map((module) => {
    const metadata = module.metadata as ArticleMetadata;
    return {
      metadata: {
        ...metadata,
        date: normalizeDate(metadata.date),
        updatedAt: normalizeDate(metadata.updatedAt),
      },
      component: module.default,
    };
  })
  .filter((article) => !article.metadata.draft)
  .sort((a, b) => b.metadata.date.localeCompare(a.metadata.date));

export const articleMetadata = articles.map(({ metadata }) => metadata);
