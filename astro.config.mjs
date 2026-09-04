// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
  site: 'https://docs.falconoon.com',
  integrations: [
    starlight({
      title: 'Agent-Fabric',
      description: 'Publish the AI already running on your own hardware as private services your team can call.',
      customCss: ['./src/styles/brand.css'],
      // Brand falcon-eye mark: dark on light theme, white on dark theme. Keeps the
      // "agent-fabric" wordmark alongside it. favicon.svg is the palette mark.
      logo: {
        light: './src/assets/logo_dark.svg',
        dark: './src/assets/logo_white.svg',
        alt: 'Agent-Fabric',
      },
      favicon: '/favicon.svg',
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/falcons-eyes/agent-fabric-docs' },
        { icon: 'external', label: 'Console', href: 'https://app.falconoon.com' },
      ],
      // The reference/guides/sdk sections are generated/synced from the private
      // repo into src/content/docs/{reference,guides,sdk} — autogenerate keeps
      // each sidebar group in lockstep with whatever's actually published.
      // Ordering within Guides comes from each page's own `sidebar.order`
      // frontmatter (set in the source repo), so Quickstart leads.
      sidebar: [
        {
          label: 'Start here',
          items: [
            { label: 'Documentation home', slug: '' },
            { label: 'Quickstart', slug: 'guides/quickstart' },
          ],
        },
        // Ordering inside Guides comes from each page's own `sidebar.order`
        // frontmatter, set in the source repo, so the section reads as the
        // journey: get running → share access → understand → fix → evidence.
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
