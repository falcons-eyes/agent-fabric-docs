---
title: Publish a service
description: Expose a local model server, MCP tool or internal API to your private network as an addressable, capability-gated service — without opening a public port.
sidebar:
  order: 3
---

Publishing turns something already listening on `127.0.0.1` into a **named
service on your private mesh**. Nothing about the local process changes, and no
public port is opened — the service becomes reachable only to machines on your
network that hold a valid capability.

```sh
fabric serve http://127.0.0.1:11434 --name my-model --kind llm
```

That is the whole operation. The rest of this page is what the parts mean and
what to do when the defaults do not fit.

## Before you start

The machine has to be on the network already:

```sh
fabric status
```

If it reports that this machine is not joined, run [`fabric up`](/guides/connect-a-device/)
first.

## Choose the kind

`--kind` tells the mesh what protocol lives behind the address, which is what
lets a caller resolve it correctly and what determines the default action a
capability grants.

| kind | for | default action |
|---|---|---|
| `llm` | An OpenAI-compatible model server — Ollama, vLLM, llama.cpp, LM Studio | `invoke` |
| `mcp` | An MCP tool server | `read` |
| `a2a` | An agent-to-agent endpoint | `delegate` |
| `router` | A gateway in front of several models | `invoke` |
| `endpoint` | Any other HTTP API | `invoke` |
| `tcp` | A raw TCP port — a database, an SSH host | `connect` |

If you are unsure, `endpoint` is the honest choice for an HTTP API and `tcp` for
anything that is not HTTP.

## Name it for the caller

The name is what teammates type, so name the capability rather than the host:

```sh
# reads well at the call site
fabric serve http://127.0.0.1:11434 --name codegen-llm --kind llm

# does not
fabric serve http://127.0.0.1:11434 --name ollama-2 --kind llm
```

Names are per-network. Publishing a second service with an existing name on the
same network replaces the first.

## Check it landed

```sh
fabric service list
fabric service inspect codegen-llm
```

`fabric service test` performs a real request against the local address, which
distinguishes "published but the process is down" from "not published":

```sh
fabric service test codegen-llm
```

## Restrict who can reach it

By default any machine on the network can be granted access. `--scope` requires
a caller's capability to carry a matching scope, which is how you keep a service
reachable by only part of the network:

```sh
fabric serve http://127.0.0.1:8080 --name payroll-api --kind endpoint --scope finance
```

Scopes are a filter on capabilities, not a replacement for them — a caller still
needs a token. See [Grant scoped access](/guides/grant-access/).

## What the cloud learns

The control plane records the service's **name, kind and the node it is on**, so
it can broker reachability and enforce capabilities. It does not receive the
local address, and it never sees a request, a prompt or a response — those go
machine to machine over the encrypted mesh.

## Remove it

```sh
fabric service remove codegen-llm
```

Removal is immediate: existing capability tokens for the service stop resolving.

## Next

- [Grant scoped access](/guides/grant-access/) — hand someone a token for one action.
- [Give a customer a demo](/guides/customer-demos/) — time-boxed access with a revoke.
- [`fabric serve` reference](/reference/cli/) — every flag.
