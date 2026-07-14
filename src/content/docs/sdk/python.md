---
title: Python SDK
---

The Python client for the Agent-Fabric control-plane API — typed Pydantic models,
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
import agentfabric

cfg = agentfabric.Configuration(host="https://api.falconoon.com")
cfg.access_token = "dev:acme"

with agentfabric.ApiClient(cfg) as client:
    networks = agentfabric.NetworksApi(client)

    # list your networks
    for nw in networks.get_api_networks():
        print(nw.id, nw.name, nw.cidr)     # Pythonic attrs (aliased to the wire format)

    # create one
    nw = networks.post_api_networks(agentfabric.CreateNetworkRequest(name="prod"))
    print("created", nw.id)
```

## Notes

- Models are typed (`Network`, `Node`, `Service`, `CreateNetworkRequest`, …). `Network`
  uses PascalCase wire keys aliased to Pythonic attributes — so `nw.id`, `nw.cidr`
  (see the casing note in the [overview](/sdk/#one-gotcha-network-field-casing)).
- Errors raise `agentfabric.ApiException` (`.status`, `.body`); wrap calls in `try/except`.

The full endpoint + model surface is the [HTTP API reference](/reference/api/). Regenerate
from the spec with `make sdk-python`.
