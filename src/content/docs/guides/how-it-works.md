---
title: How it works
description: The mesh + control-plane model at a glance — what runs where, and what the control plane does and doesn't see.
sidebar:
  order: 2
---

# How it works

A short, honest overview of the trust model — enough to evaluate whether
agent-fabric fits your infrastructure, without the implementation detail.

## Two things run, in two different places

**Your machines** run the actual work: model servers, agents, tools, databases —
whatever you connect. **The control plane** (`app.falconoon.com` / `api.falconoon.com`)
is a coordination service we operate. It never runs your workloads and never sees
your traffic.

```
┌─────────────────────────┐
│      Control plane        │   brokers identity, keys, and policy
│  (accounts · networks ·   │   — never on the data path
│   capabilities · billing) │
└────────────┬───────────┘
             │  (control only: enroll, network map, capability tokens)
   ┌─────────┴─────────┐
   │                       │
┌──▼───────┐        ┌──▼───────┐
│ Machine A │◄──────►│ Machine B │   encrypted, peer-to-peer
│ (yours)   │  WireGuard  │ (yours)   │   (direct, or relayed if NAT requires it)
└──────────┘        └──────────┘
```

## What the control plane does

- **Identity and membership** — who's on your team, which machines belong to which
  network.
- **The network map** — a signed, tamper-evident list of which machines exist and
  how to reach them, refreshed continuously.
- **Capabilities** — short-lived, scoped tokens that say "this caller may invoke
  this one service" — the mechanism that lets a teammate's machine reach a service
  on yours without a shared secret or an open port.
- **Relay fallback** — when two machines can't establish a direct peer-to-peer
  path (a strict NAT/firewall), traffic is relayed as opaque, still end-to-end
  encrypted bytes. The relay forwards; it cannot read the payload.

## What it never sees

- **Your traffic.** Connections between your machines are WireGuard-encrypted
  peer-to-peer. When a relay is in the path, it forwards ciphertext — the control
  plane and relay never hold a decryption key.
- **Prompts, model outputs, or application data.** Nothing you run — model
  servers, agent sessions, databases — sends its payloads to the cloud. What
  reaches the cloud is metadata: that a service exists, its name and kind, and
  whether it's reachable.
- **Your private keys.** Each machine generates its own WireGuard key locally and
  it never leaves the machine.

## The building blocks

| Concept | What it is |
|---|---|
| **Network** | A private group of your machines, isolated from every other org's. |
| **Device / machine** | Anything you connect with `falcon up` — a laptop, a server, a GPU box. |
| **Service** | Something running on a machine that you make addressable to the mesh (`falcon serve`) — a model endpoint, an MCP tool, an internal API. |
| **Capability** | A scoped, expiring token that grants one caller one action on one service — the access-control primitive everything else is built on. |
| **Demo Room** | Time-boxed, revocable access to one service for someone outside your org — for showing a customer a live demo without opening a public port. |

## Where to go next

- **[Quickstart](/guides/quickstart/)** — install and connect your first machine.
- **[Connect a device](/guides/connect-a-device/)** — the day-to-day workflow.
- **[HTTP API reference](/reference/api/)** — for building against the control plane directly.
