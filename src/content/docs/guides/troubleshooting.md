---
title: Troubleshooting
description: Work from the symptom you actually have — a machine that will not join, a name that will not resolve, a refused capability, or a call that hangs — to the one command that tells you which layer is at fault.
sidebar:
  order: 8
---

Four commands answer almost everything, and they answer about different layers.
Running the right one first saves the most time:

| command | answers |
|---|---|
| `fabric doctor` | Is *this machine's* setup sound — config, identity, keystore, control plane? |
| `fabric netcheck` | Can this machine reach the mesh — control, netmap, relay, NAT, per-peer path? |
| `fabric ping <name>` | Can it reach *that specific peer*, and by which path? |
| `fabric try <service>` | Does the whole loop work — capability, gateway, real call? |

All four take `--json`, which is what to use from a script or when pasting into
a support thread.

## The machine will not join

```sh
fabric doctor
```

`doctor` checks the local half first, in order: is there config, is there an
identity, is the keystore readable, can the control plane be reached. The first
failing line is the cause — the ones after it are consequences.

- **No config / no identity** — the machine was never signed in. Run `fabric up`.
- **Keystore unreadable** — usually a permissions change or a copied home
  directory. Sign in again on this machine rather than copying credentials.
- **Control plane unreachable** — network or proxy, not Agent-Fabric. Confirm
  with an ordinary HTTPS request to the same host.

## It joined, but nothing can reach it

```sh
fabric netcheck
```

This is the mesh layer. It reports control-plane reachability, whether the
netmap arrived, whether the relay is available, what NAT this machine is behind,
and the path to each peer.

- **Netmap missing** — the machine is authenticated but has not been given the
  network's map yet. `fabric wait` blocks until readiness holds, and fails at
  its timeout rather than hanging forever.
- **No direct path, relay unavailable** — two machines behind hostile NAT with
  no relay is the one combination that cannot connect. The relay is what makes
  that case work; confirm the plan includes relay traffic.
- **Direct path, still unreachable** — suspect a local firewall on the *other*
  machine.

## A name will not resolve

```sh
fabric names
fabric whois <name>
```

`names` lists what this machine can actually resolve right now. If the service
is missing from that list, the problem is publication, not networking:

```sh
# on the machine hosting it
fabric service list
fabric service test <name>
```

`service test` calls the local address. It separates the two failures that look
identical from the outside: **published but the local process is down**, and
**never published**.

## The capability is refused

A refusal is the gateway working, so read it literally.

- **Wrong action.** The action must match the service kind — `invoke` for a
  model, `read` for MCP, `delegate` for A2A, `connect` for TCP. See
  [Grant scoped access](/guides/grant-access/).
- **Expired.** Tokens default to 10 minutes. Mint another; there is nothing to
  reconfigure.
- **Scope mismatch.** If the service was published with `--scope`, the
  capability has to carry it. Check with `fabric service inspect <name>`.

To see the whole loop pass and fail on purpose:

```sh
fabric try <service>
```

`try` mints a capability, has the gateway authorize it, proves the same request
is refused *without* a token, and — for a model — makes one real call. If `try`
passes and your own client does not, the fault is in the client.

## A call connects but hangs

The mesh delivered it; the service did not answer. Check the process on the
hosting machine, then:

```sh
fabric ping <node>
```

If ping reports a **relay** path, throughput is bounded by the relay and a large
model response can appear to hang. A direct path is preferable; `netcheck` on
both machines says why one was not established.

## The console disagrees with the CLI

Almost always two different workspaces. Check which the CLI is in:

```sh
fabric whois
```

and compare it with the workspace shown in the Cloud Console. In development
mode the console signs in with an unauthenticated `dev:<org>` token, which is
easy to point at a different org than the CLI.

## Collecting a report

```sh
fabric doctor --json > doctor.json
fabric netcheck --json > netcheck.json
```

Neither contains prompts, model outputs or capability tokens. They are safe to
attach to a support request at <support@falconoon.com>.

## Next

- [How it works](/guides/how-it-works/) — what each layer is responsible for.
- [CLI reference](/reference/cli/) — every flag on every diagnostic.
