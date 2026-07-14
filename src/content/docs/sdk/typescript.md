---
title: TypeScript SDK
---

The TypeScript client for the Agent-Fabric control-plane API — axios-based, typed models,
generated from the [OpenAPI spec](/openapi.yaml) so it never drifts from the server.
New here? Start with the [SDKs overview](/sdk/) for the auth model and base URLs.

## Install

```sh
npm install ./sdk/typescript    # from a checkout (or @agentfabric/sdk once published)
```

## Authenticate and make a call

Build a `Configuration` with the base URL and a bearer token (prod: your Cognito OIDC
access token · dev: `dev:<workspace>`), then call an API. Each resource has its own
`*Api` class; every method returns an axios response (`{ data, status, … }`).

```ts
import { Configuration, NetworksApi } from "@agentfabric/sdk";

const config = new Configuration({
  basePath: "https://api.falconoon.com",
  accessToken: "dev:acme",
});

const networks = new NetworksApi(config);

// list your networks
const { data: list } = await networks.getApiNetworks();
for (const nw of list) console.log(nw.ID, nw.Name, nw.CIDR);

// create one
const { data: nw } = await networks.postApiNetworks({ name: "prod" });
console.log("created", nw.ID);
```

## Notes

- Fully typed — models resolve via `package.json`, so editor autocomplete works in TS
  and JS. `Network` uses PascalCase wire keys (`nw.ID`, `nw.CIDR`) — see the casing note
  in the [overview](/sdk/#one-gotcha-network-field-casing).
- Errors reject as axios errors; inspect `err.response?.status` / `err.response?.data`.

The full endpoint + model surface is the [HTTP API reference](/reference/api/). Regenerate
from the spec with `make sdk-typescript`.
