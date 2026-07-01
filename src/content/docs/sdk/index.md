---
title: SDKs
---


Client SDKs for the FalconEyes control-plane API, **generated from the OpenAPI spec**
([`docs/reference/openapi.yaml`](../docs/reference/openapi.yaml)) — the single source of
truth, kept in lockstep with the chi router by `TestEndpointDocsMatchRouter`. Generating
from the spec means the SDK can never silently drift from the API.

## Available

| Language | Path | Status |
|---|---|---|
| Python | [`sdk/python`](python) | ✅ generated (urllib3, typed models) |
| TypeScript | [`sdk/typescript`](typescript) | ✅ generated (axios, typed models) |
| Go | [`sdk/go`](go) | ✅ generated (separate module `github.com/falcons-eyes/falconeyes-go`) |

## Python

The core resource models are fully typed (`Network`, `Node`, `Service`, `Workspace`,
`UsageResponse`, …) with request bodies (`CreateNetworkRequest`, `EnrollRequest`, …). The
remaining endpoints are present but body-less until their schemas are added to the spec.

```python
import falconeyes

cfg = falconeyes.Configuration(host="https://api.falconoon.com")
cfg.access_token = "<bearer token>"          # Cognito OIDC in prod, or dev:<org> in dev mode

with falconeyes.ApiClient(cfg) as client:
    networks = falconeyes.NetworksApi(client).get_api_networks()   # -> list[Network]
    for nw in networks:
        print(nw.id, nw.name, nw.cidr)                             # typed fields
```

Install (editable, from a checkout):

```sh
pip install ./sdk/python
```

Per-endpoint and per-model docs are generated under [`sdk/python/docs`](python/docs).

> Note on field casing: `Network` is serialized with Go field names (PascalCase JSON keys:
> `ID`, `OrgID`, `CIDR`, …) while the other resources use snake_case. The generated client
> exposes Pythonic attribute names and handles the JSON aliasing — the SDK is faithful to
> the wire format.

## Regenerating

The SDK is committed (reviewable + installable) and regenerated from the spec with Docker —
no local Python/pip toolchain required:

```sh
make docs          # regenerate docs/reference/openapi.yaml from the Go source
make sdk-python    # regenerate sdk/python from the spec (uses openapitools/openapi-generator-cli)
```

To widen the typed surface, add request/response schemas to `cmd/docsgen` (`coreSchemas` +
`endpointBodies`) and re-run both targets.
