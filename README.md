# agent-fabric-docs

Public documentation for **agent-fabric**, served at **docs.falconoon.com**. Built
with [Starlight](https://starlight.astro.build) (Astro).

> **One-way sync — do not hand-edit `src/content/docs/reference/` or
> `src/content/docs/guides/`.**
> Reference pages are generated from source code in the private `agent-fabric`
> repo (`cmd/docsgen`). Guides under `guides/` are source-owned public docs from
> that same repo. Hand edits are overwritten on the next sync. Edit the private
> repo source docs or generator instead. Authored site shell pages, such as the
> homepage, live elsewhere under `src/content/docs/`.

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
- **Guides** (`guides/*`): source-owned public guides copied from the private repo
  by the same publish workflow.
- **Everything else** (homepage and site shell): authored here.

Branches: `main` tracks the live site; the publish job updates `main` from the
private repo's `main` and uses `v*` branches for version snapshots.
