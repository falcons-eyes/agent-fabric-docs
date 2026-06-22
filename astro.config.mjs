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
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/falcons-eyes/agent-fabric' },
      ],
      // The reference section is generated in the private repo and synced into
      // src/content/docs/reference/ — autogenerate keeps the sidebar in lockstep.
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
      ],
    }),
  ],
});
