---
title: Give a customer a demo
description: Hand a prospect real, time-boxed access to a private service through a demo room — no public port, a clock you can extend, and a revoke you can hit at any time.
sidebar:
  order: 5
---

A demo room is **time-boxed access to one of your private services, for someone
outside your network**. It exists because the alternatives are both bad: giving a
prospect a raw capability token means you cannot take it back, and standing up a
public endpoint means opening the thing you bought Agent-Fabric to avoid.

A room has an owner, a clock, a usage counter and a revoke.

## Create one

Demo rooms are created in the [Cloud Console](https://app.falconoon.com/demos)
rather than from the CLI, because the thing you hand over is a link and the thing
you watch afterwards is a dashboard.

1. Publish the service you want to show — see [Publish a service](/guides/publish-a-service/).
2. Open **Delivery → Demo rooms** and choose **New demo**.
3. Pick the service, name the room after the customer, and set an expiry.

You get back a shareable connection bundle. Send that; the customer needs
nothing else and never touches your network directly.

## What the customer can and cannot do

They can call the one service the room was created for, with the one action its
kind implies, until the room expires or you close it.

They cannot reach any other service, see your other machines, or keep the access
after the clock runs out. The traffic still goes to the machine hosting the
service — it is not proxied through a public endpoint — and prompts and outputs
never reach the control plane.

## Watch it

The room's row on the Delivery board shows its state and its clock, and the
detail page adds a live readiness check: whether the room is active, whether the
service is still published, and whether the machine backing it is online. A demo
that fails at the customer's end usually fails one of those three, and the page
says which.

## Extend, re-issue, revoke

| you want to | do this |
|---|---|
| Give them longer | **Extend** — pushes the expiry out and issues a fresh token |
| They lost the link | **Copy token** — re-issues a token scoped to the *remaining* time |
| Stop it now | **Revoke** — closes the room and pulls the expiry to now |
| Clean up afterwards | **Delete** — removes the room entirely |

Revoke takes effect immediately: the next call the customer makes is refused.
There is no grace period to reason about.

## Limits

A room can carry a usage cap and a rate limit as well as an expiry, which is
worth setting when the service costs you real GPU time. Both are editable after
creation.

## Which mechanism to use

| situation | use |
|---|---|
| A teammate, at their keyboard, right now | [A capability token](/guides/grant-access/) |
| Automation inside your own network | A capability token with a longer TTL |
| Someone outside your team | **A demo room** |
| A customer environment you operate for them | Customer environments in the console |

## Next

- [Grant scoped access](/guides/grant-access/) — the lighter mechanism, for teammates.
- [Troubleshooting](/guides/troubleshooting/) — when a customer says it does not work.
- [HTTP API reference](/reference/api/) — `POST /api/demo-rooms` and friends, for automating this.
