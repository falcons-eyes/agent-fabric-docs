---
title: SDKs
---


Call the FalconEyes control-plane API from your own code — list networks and devices,
publish and reach private services, read usage — in Python, TypeScript, or Go. Every
SDK is **generated from the [OpenAPI spec](/openapi.yaml)** and stays in sync with the
live API, so the client never silently drifts from the server.

## CLI or SDK?

- **Just want to connect a machine and publish a local AI?** Use the [`fabric` CLI](/reference/cli/) —
  `fabric quickstart` does the whole thing in one flow. That's the fastest path for a person.
- **Automating from your own app, service, or CI?** Use an SDK below. It speaks the same
  API the CLI and console do.

## Authentication

Every request carries a **bearer token**. Point the SDK at your control plane and set the token:

| | Base URL | Token |
|---|---|---|
| **Production** | `https://api.falconoon.com` | your Cognito OIDC access token |
| **Local dev** | `http://127.0.0.1:8080` | `dev:<workspace>` (e.g. `dev:acme`) |

In dev mode the token is literally the string `dev:` + your workspace name — no auth server
needed. In production the token is an OIDC access token from your identity provider; treat it
like any other secret (environment variable, secrets manager — never commit it).

## Quickstart

Each example does the same thing: authenticate and list your networks.

### Python

```python
import falconeyes

cfg = falconeyes.Configuration(host="https://api.falconoon.com")
cfg.access_token = "dev:acme"          # dev; or your Cognito OIDC bearer in prod

with falconeyes.ApiClient(cfg) as client:
    for nw in falconeyes.NetworksApi(client).get_api_networks():
        print(nw.id, nw.name, nw.cidr)  # Pythonic attributes (aliased to the wire format)
```

```sh
pip install ./sdk/python        # from a checkout
```

### TypeScript

```ts
import { Configuration, NetworksApi } from "@falconeyes/sdk";

const config = new Configuration({
  basePath: "https://api.falconoon.com",
  accessToken: "dev:acme",             // dev; or your Cognito OIDC bearer in prod
});

const { data: networks } = await new NetworksApi(config).getApiNetworks();
for (const nw of networks) console.log(nw.ID, nw.Name, nw.CIDR);
```

```sh
npm install ./sdk/typescript    # from a checkout (or @falconeyes/sdk once published)
```

### Go

```go
import (
    "context"
    "fmt"

    falconeyes "github.com/falcons-eyes/falconeyes-go/falconeyes"
)

cfg := falconeyes.NewConfiguration()   // Servers[0] is https://api.falconoon.com
client := falconeyes.NewAPIClient(cfg)

ctx := context.WithValue(context.Background(), falconeyes.ContextAccessToken, "dev:acme")
nets, _, err := client.NetworksAPI.GetApiNetworks(ctx).Execute()
if err != nil {
    panic(err)
}
for _, nw := range nets {
    fmt.Println(nw.GetID(), nw.GetName(), nw.GetCIDR())
}
```

```go
import falconeyes "github.com/falcons-eyes/falconeyes-go/falconeyes"  // then: go mod tidy
```

## One gotcha: `Network` field casing

`Network` is serialized with Go field names (PascalCase JSON keys: `ID`, `OrgID`, `CIDR`, …);
most other resources use `snake_case`. Each SDK is faithful to that wire format, so the field
names you type differ by language — as the quickstarts show:

| Field | Python | TypeScript | Go |
|---|---|---|---|
| id | `nw.id` | `nw.ID` | `nw.GetID()` |
| name | `nw.name` | `nw.Name` | `nw.GetName()` |
| cidr | `nw.cidr` | `nw.CIDR` | `nw.GetCIDR()` |

Python aliases the PascalCase keys to Pythonic attribute names; TypeScript and Go expose the
keys as-is. Editor autocomplete on the typed models is the reliable guide.

## Coverage

The core resource models are fully typed — `Network`, `Node`, `Service`, `Workspace`,
`UsageResponse`, and request bodies like `CreateNetworkRequest` and `EnrollRequest`. Endpoints
whose bodies aren't yet in the spec are present but body-less; to widen the typed surface, add
their schemas to `cmd/docsgen` (`coreSchemas` + `endpointBodies`) and regenerate.

The complete endpoint + model surface is the [HTTP API reference](/reference/api/).

| Language | Path | Client |
|---|---|---|
| Python | [`sdk/python`](python) | urllib3, typed Pydantic models |
| TypeScript | [`sdk/typescript`](typescript) | axios, typed models |
| Go | [`sdk/go`](go) | net/http, module `github.com/falcons-eyes/falconeyes-go` |

## Regenerating

The SDKs are committed (reviewable + installable) and regenerated from the spec with Docker —
no local Python/Node/Go toolchain required:

```sh
make docs          # regenerate docs/reference/openapi.yaml from the Go source
make sdk           # regenerate all three SDKs from the spec
```
