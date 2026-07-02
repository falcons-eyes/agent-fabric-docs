// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
  site: 'https://docs.falconoon.com',
  integrations: [
    starlight({
      title: 'agent-fabric',
      description: 'Managed trust and connectivity for customer-owned AI.',
      customCss: ['./src/styles/brand.css'],
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/falcons-eyes/agent-fabric' },
      ],
      // The reference/guides/sdk sections are generated/synced from the private
      // repo into src/content/docs/{reference,guides,sdk} — autogenerate keeps
      // each sidebar group in lockstep with whatever's actually published.
      // Ordering within Guides comes from each page's own `sidebar.order`
      // frontmatter (set in the source repo), so Quickstart leads.
      sidebar: [
        {
          label: 'Start here',
          items: [{ label: 'Overview', slug: '' }],
        },
        {
          label: 'Guides',
          items: [{ autogenerate: { directory: 'guides' } }],
        },
        {
          label: 'Reference',
          items: [{ autogenerate: { directory: 'reference' } }],
        },
        {
          label: 'SDKs',
          items: [{ autogenerate: { directory: 'sdk' } }],
        },
      ],
    }),
  ],
});
