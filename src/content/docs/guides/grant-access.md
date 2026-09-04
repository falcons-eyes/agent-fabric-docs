---
title: Grant scoped access
description: Mint a short-lived capability token for one action on one service, hand it to a teammate, and let it expire instead of reconfiguring anything.
sidebar:
  order: 4
---

A capability is a **signed token for one action on one service, with an expiry**.
It is not a network hole and not an account: nothing about the service changes
when you issue one, and nothing needs changing when it expires.

```sh
fabric grant llm://codegen-llm --action invoke --ttl 30m
```

The output is the token. Give it to whoever needs the access.

## Using it

The holder exchanges the token for the live coordinates of the service:

```sh
fabric resolve codegen-llm --action invoke --cap <token>
```

The gateway checks the capability before answering. A resolve without a valid
token is refused, so the token — not network position — is what grants reach.
From there the caller talks to the service directly over the mesh; the exchange
is the last time the control plane is involved.

## Choosing the action

The action must match what the caller will actually do. Granting more than they
need is the whole thing this mechanism exists to avoid.

| service kind | usual action |
|---|---|
| `llm`, `router`, `endpoint` | `invoke` |
| `mcp` | `read` |
| `a2a` | `delegate` |
| `tcp` | `connect` |

## Choosing a lifetime

`--ttl` defaults to **10 minutes**, which is right for handing someone a token
in chat while they are at their keyboard. Longer lifetimes are for automation
that cannot be re-issued interactively.

```sh
fabric grant mcp://local-files --action read --ttl 8h
```

Prefer a short lifetime and a re-issue over a long one you will forget about.
There is no revoke-a-single-token command by design — the expiry is the revoke,
which is why it is worth setting deliberately.

:::note
If you need access that outlives a working session and that you can withdraw on
demand, you want a demo room rather than a raw token — it has an owner, a clock
you can extend, and a one-click revoke. See
[Give a customer a demo](/guides/customer-demos/).
:::

## Scoped services

If the service was published with `--scope`, a capability only works when it
carries the matching scope. Publishing and granting have to agree:

```sh
# on the machine hosting it
fabric serve http://127.0.0.1:8080 --name payroll-api --kind endpoint --scope finance

# when granting
fabric grant endpoint://payroll-api --action invoke --ttl 1h
```

A caller without the scope gets a refusal from the gateway, not a timeout.

## Scripting it

`--json` gives a parseable result rather than the human-readable block:

```sh
TOKEN=$(fabric grant llm://codegen-llm --action invoke --ttl 15m --json | jq -r .token)
fabric resolve codegen-llm --action invoke --cap "$TOKEN" --json
```

## What the cloud learns

The control plane mints and verifies the capability, so it knows **that** a
token was issued for a resource and an action, and it counts the resolve. It
does not see the traffic that follows — the caller reaches the service directly
over the encrypted mesh.

## Next

- [Give a customer a demo](/guides/customer-demos/) — revocable access with an owner.
- [Troubleshooting](/guides/troubleshooting/) — when a resolve is refused.
- [`fabric grant` and `fabric resolve` reference](/reference/cli/).
