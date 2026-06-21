# agent-fabric-docs

Public documentation for **agent-fabric**, served at **docs.falconoon.com**. Built
with [Starlight](https://starlight.astro.build) (Astro).

> **One-way sync — do not hand-edit `src/content/docs/reference/`.**
> Those pages are *generated from source code* in the private `agent-fabric` repo
> (`cmd/docsgen`) and pushed here by CI. Hand edits are overwritten on the next
> sync. Edit the code (or the generator) instead. Authored pages — the homepage
> and guides — live elsewhere under `src/content/docs/` and are safe to edit here.

## Develop

```sh
npm install
npm run dev      # local preview at http://localhost:4321
npm run build    # production build → dist/
```

## How content gets here

- **Reference** (`reference/cli`, `reference/api`, `reference/config`): generated
  in the private repo from the cobra command tree, the chi router and the config
  env table, then synced by the `docs-publish` workflow. A CI drift gate in the
  private repo fails the build if the generated docs fall out of step with the code.
- **Everything else** (homepage, guides): authored here.

Branches: `main` tracks the latest release; the publish job uses `next` for
in-development docs and `v*` branches for version snapshots.
