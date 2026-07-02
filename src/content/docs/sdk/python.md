---
title: Python SDK
---

The Python client for the FalconEyes control-plane API — typed Pydantic models,
generated from the [OpenAPI spec](/openapi.yaml) so it never drifts from the server.
New here? Start with the [SDKs overview](/sdk/) for the auth model and base URLs.

## Install

```sh
pip install ./sdk/python        # from a checkout
```

## Authenticate and make a call

Set the base URL and a bearer token (prod: your Cognito OIDC access token · dev:
`dev:<workspace>`), then call an API. Each resource has its own `*Api` class.

```python
import falconeyes

cfg = falconeyes.Configuration(host="https://api.falconoon.com")
cfg.access_token = "dev:acme"

with falconeyes.ApiClient(cfg) as client:
    networks = falconeyes.NetworksApi(client)

    # list your networks
    for nw in networks.get_api_networks():
        print(nw.id, nw.name, nw.cidr)     # Pythonic attrs (aliased to the wire format)

    # create one
    nw = networks.post_api_networks(falconeyes.CreateNetworkRequest(name="prod"))
    print("created", nw.id)
```

## Notes

- Models are typed (`Network`, `Node`, `Service`, `CreateNetworkRequest`, …). `Network`
  uses PascalCase wire keys aliased to Pythonic attributes — so `nw.id`, `nw.cidr`
  (see the casing note in the [overview](/sdk/#one-gotcha-network-field-casing)).
- Errors raise `falconeyes.ApiException` (`.status`, `.body`); wrap calls in `try/except`.

The full endpoint + model surface is the [HTTP API reference](/reference/api/). Regenerate
from the spec with `make sdk-python`.
