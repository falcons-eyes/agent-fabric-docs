---
title: Go SDK
---

The Go client for the FalconEyes control-plane API — `net/http`-based, typed models,
generated from the [OpenAPI spec](/openapi.yaml) so it never drifts from the server.
New here? Start with the [SDKs overview](/sdk/) for the auth model and base URLs.

## Install

```go
import falconeyes "github.com/falcons-eyes/falconeyes-go/falconeyes"  // then: go mod tidy
```

## Authenticate and make a call

`NewConfiguration()` defaults `Servers[0]` to `https://api.falconoon.com`. Pass the bearer
token (prod: your Cognito OIDC access token · dev: `dev:<workspace>`) via the request
context. Each resource is a service on the client; calls use a request-builder + `Execute()`.

```go
import (
    "context"
    "fmt"

    falconeyes "github.com/falcons-eyes/falconeyes-go/falconeyes"
)

cfg := falconeyes.NewConfiguration()
client := falconeyes.NewAPIClient(cfg)
ctx := context.WithValue(context.Background(), falconeyes.ContextAccessToken, "dev:acme")

// list your networks
nets, _, err := client.NetworksAPI.GetApiNetworks(ctx).Execute()
if err != nil {
    panic(err)
}
for _, nw := range nets {
    fmt.Println(nw.GetID(), nw.GetName(), nw.GetCIDR())
}

// create one
nw, _, err := client.NetworksAPI.PostApiNetworks(ctx).
    CreateNetworkRequest(falconeyes.CreateNetworkRequest{Name: "prod"}).Execute()
if err != nil {
    panic(err)
}
fmt.Println("created", nw.GetID())
```

## Notes

- Typed models with `GetX()` accessors. `Network` uses PascalCase wire keys, so it's
  `nw.GetID()`, `nw.GetCIDR()` — see the casing note in the
  [overview](/sdk/#one-gotcha-network-field-casing).
- `Execute()` returns `(value, *http.Response, error)`; check `err` and, if you need it,
  the raw response for the status code.

The full endpoint + model surface is the [HTTP API reference](/reference/api/). Regenerate
from the spec with `make sdk-go`.
