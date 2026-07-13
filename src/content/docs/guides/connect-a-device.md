---
title: Connect a device
description: Sign in and join a machine to your private network in one command with fabric up, then see it in the cloud console — without sending traffic, prompts, or outputs to the cloud.
sidebar:
  order: 3
---

# Connect a device

The **cloud console** at [app.falconoon.com](https://app.falconoon.com) manages your
*fabric and account* — networks, devices, services, usage, and billing. The
`fabric` CLI connects a machine to that fabric. Your traffic stays end-to-end
encrypted (WireGuard) and peer-to-peer; the control plane brokers keys, identity,
and network maps but never sees your data.

## One command: `fabric up`

On the machine you want to connect:

```sh
fabric up --network <network-id> --name my-device
```

`fabric up` does three things:

1. **Signs you in** with the browser device flow (OAuth 2.0 Device Authorization
   Grant, RFC 8628). It prints a short code and a URL; you approve it from any
   browser — so it works on a headless server or inside a container with no local
   browser.
2. **Joins** this machine to the network: it generates a WireGuard key, proves the
   device's identity, enrolls, and fetches the signed network map. The private key
   never leaves the machine.
3. Reports the **overlay IP** and guides bringing up the tunnel (the `afd` node
   agent).

Copy the exact command (with your network id pre-filled) from the console:
**Networks → open a network → Connect a device**.

> `fabric up` ≠ `fabric login` (just authenticate) ≠ console "revoke device"
> (remove membership). `fabric down` disconnects the machine while keeping your
> login and identity.

## See it in the console

Open [app.falconoon.com](https://app.falconoon.com):

- **Devices** — every connected machine, its overlay IP, online/offline, client
  version, and the services it publishes.
- **Networks** — your private networks and their devices.
- **Dashboard** — a fleet overview (networks, devices online, usage, subscription).

## Publish a local service

Make a locally-running model server or tool reachable across the mesh as a
private, addressable service:

```sh
fabric serve http://127.0.0.1:11434 --name mac-ollama --kind llm
```

It becomes `mac-ollama.<device>.private`, visible under **Services** in the
console and resolvable by peers via a capability. Only *metadata* (name, kind,
node, private name) reaches the cloud — never prompts or outputs.

## Everyday verbs

| Command | What it does |
|---|---|
| `fabric ip` | print this machine's overlay IP (bare, for scripts) |
| `fabric wait` | block until ready (overlay IP + signed netmap) — for CI |
| `fabric names` | list private node/service names from the signed netmap |
| `fabric whois <ip\|name>` | resolve an overlay IP or private name to its owner |
| `fabric status` | this node's peers, paths, and services |
| `fabric down` | disconnect this machine (keeps your login) |

See the full [CLI reference](/reference/cli/) for every command and flag.
