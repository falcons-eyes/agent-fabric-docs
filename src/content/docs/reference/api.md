---
title: HTTP API reference
---

Every route needs your workspace bearer token — `Authorization: Bearer <token>` (Cognito OIDC in production, `dev:<workspace>` in local dev) — except the few marked **public**. A suspended network gets `402 Payment Required` on the billable routes.

Prefer calling this API from code? The [SDKs](/sdk/) (Python / TypeScript / Go) and the [OpenAPI spec](/openapi.yaml) cover the same surface.

## Service health

Unauthenticated probes for monitors and load balancers.

- `GET /healthz` *(public)* — liveness probe
- `GET /readyz` *(public)* — readiness probe — 503 until the datastore is reachable
- `GET /metrics` *(public)* — Prometheus metrics (RED: rate/errors/duration); optionally gated by AF_METRICS_TOKEN

## Sign-in & device sessions

The browser device flow (RFC 8628) the CLI uses, plus session management.

- `POST /device/code` *(public)* — device-flow: request a device + user code (RFC 8628)
- `POST /device/token` *(public)* — device-flow: poll for tokens (grant_type=device_code|refresh_token)
- `POST /api/device/approve` — approve a device-flow user code (binds it to the caller)
- `POST /api/device/deny` — deny a device-flow user code
- `GET /api/device/pending` — device-flow grant awaiting approval (client name + request IP)
- `GET /api/device/sessions` — list the caller's active CLI/device sessions
- `DELETE /api/device/sessions/{id}` — revoke a device session

## Workspace & members

Your org profile, roster, and invitations.

- `GET /api/workspace` — workspace (org) profile — name, plan, owner
- `POST /api/workspace/bootstrap` — first-run setup: create the org + a Default network (idempotent, no-op once bootstrapped)
- `PATCH /api/workspace` — rename the workspace (label change only)
- `GET /api/workspace/members` — workspace roster — owner + invitations
- `PATCH /api/workspace/members/{subject}` — change a member's role (owner-only; owner|member); the last owner cannot be demoted
- `DELETE /api/workspace/members/{subject}` — remove a member (owner-only); the last owner cannot be removed
- `GET /api/workspace/invitations` — list the caller org's invitations
- `POST /api/workspace/invitations` — invite a teammate by email + role (admin|member)
- `POST /api/workspace/invitations/{id}/accept` — accept an invitation addressed to your email — join the inviting org
- `DELETE /api/workspace/invitations/{id}` — revoke an invitation

## Networks

Private overlay networks and their subscription state.

- `POST /api/networks` — create a private network
- `GET /api/networks` — list the caller org's networks
- `PATCH /api/networks/{id}` — rename a network (label change only)
- `DELETE /api/networks/{id}` — delete an empty network (409 if nodes remain)
- `GET /api/networks/{id}/billing` — network subscription status (plan, entitlement, renews_at) — no payment credential

## Machines & published services

Enroll devices, manage nodes, publish services on them, and drive desired-state jobs.

- `POST /api/enroll` — enroll a node (device proof-of-possession optional); 402 if suspended
- `GET /api/nodes` — list nodes (?network_id=)
- `DELETE /api/nodes/{id}` — delete a node (revoke membership)
- `PATCH /api/nodes/{id}` — rename a node (keeps id + overlay IP)
- `POST /api/nodes/{id}/revoke` — revoke a node's device identity (blocks re-enroll) + remove it
- `POST /api/nodes/{id}/heartbeat` — node liveness + reachability candidates
- `POST /api/nodes/{id}/services` — attach a private service (mcp/a2a/llm/…)
- `DELETE /api/nodes/{id}/services/{name}` — remove a published service from a node
- `POST /api/nodes/{id}/jobs` — enqueue an allow-listed desired-state job for a node
- `GET /api/nodes/{id}/jobs` — list a node's desired-state jobs (?status=pending for the node poll)
- `GET /api/nodes/{id}/capabilities` — what a node can be used as (gpu/model_server/tool_server/agent_host/gateway), derived from reported state
- `POST /api/jobs/{id}/status` — node reports a job's reconciled state (applied|failed|rejected)

## Network map & connectivity

The signed peer map, its verify key, and relay admission.

- `GET /api/netmap/{id}` — signed network map (peers + entitlement envelope)
- `GET /api/control-key` — Ed25519 netmap verify key (+ key_id)
- `GET /api/relay/{id}` — relay endpoint + signed admission ticket; 402 if suspended

## Capability tokens & service resolution

Mint scoped tokens and resolve private services through the gateway.

- `POST /api/capabilities` — issue a macaroon-style capability token
- `POST /api/gateway/resolve` — resolve a service via a capability; 402 if suspended

## Remote console access

Zero-trust ACL grants for reaching a machine's Local Console.

- `POST /api/console/access` — request remote Local Console access → node-scoped capability (403 if no ACL grant)
- `POST /api/console/verify` — node forwarder: verify a console capability + re-check the ACL (fail-closed)
- `POST /api/console/grants` — grant a subject console access to a node (zero-trust ACL)
- `GET /api/console/grants` — list a network's console ACL grants (?network_id=)
- `DELETE /api/console/grants` — revoke a console ACL grant

## Demo rooms

Time-boxed customer access to a published service.

- `POST /api/demo-rooms` — create a demo room — time-boxed customer access to a service (Idempotency-Key supported); returns a scoped connection token
- `GET /api/demo-rooms` — list the caller org's demo rooms
- `GET /api/demo-rooms/{id}` — demo room detail (derived status + control-page URL)
- `PATCH /api/demo-rooms/{id}` — update a demo room (name, usage/rate limits)
- `DELETE /api/demo-rooms/{id}` — delete a demo room
- `POST /api/demo-rooms/{id}/revoke` — close a demo room (status→revoked, expiry pulled to now)
- `POST /api/demo-rooms/{id}/extend` — extend/reactivate a demo room → fresh connection token
- `POST /api/demo-rooms/{id}/token` — re-issue a connection token scoped to the remaining TTL (409 if not active)
- `GET /api/demo-rooms/{id}/status` — live demo health: status, expiry, node online, service present

## GPU workspaces

Team model endpoints backed by your GPU machines.

- `POST /api/gpu-workspaces` — register a GPU node as a team model endpoint (auto-discovers published model services)
- `GET /api/gpu-workspaces` — list the caller org's GPU workspaces
- `GET /api/gpu-workspaces/{id}` — GPU workspace detail
- `PATCH /api/gpu-workspaces/{id}` — update a GPU workspace (name)
- `DELETE /api/gpu-workspaces/{id}` — delete a GPU workspace
- `GET /api/gpu-workspaces/{id}/detect` — detect the node's GPU/runtime capabilities + published model services
- `POST /api/gpu-workspaces/{id}/register-service` — link an already-published model service on the node into the workspace
- `DELETE /api/gpu-workspaces/{id}/services/{name}` — unlink a model service from the workspace (inverse of register-service)
- `POST /api/gpu-workspaces/{id}/publish-service` — remotely publish a loopback model service on the GPU node via an APPLY_RECIPE job (async)
- `GET /api/gpu-workspaces/{id}/client-config` — OpenAI-compatible base URL + scoped capability token for a model service (?service=)

## Agent workspaces

Group agent + model + tool services into a working unit.

- `POST /api/agent-workspaces` — group agent + model + tool services into a working-agent workspace
- `GET /api/agent-workspaces` — list the caller org's agent workspaces
- `GET /api/agent-workspaces/{id}` — agent workspace detail
- `PATCH /api/agent-workspaces/{id}` — update an agent workspace (name, purpose)
- `DELETE /api/agent-workspaces/{id}` — delete an agent workspace
- `POST /api/agent-workspaces/{id}/services` — attach a service to the workspace (routed to its leg by kind)
- `POST /api/agent-workspaces/{id}/publish-service` — remotely publish a loopback service on a node in the network via an APPLY_RECIPE job (async)
- `DELETE /api/agent-workspaces/{id}/services` — detach a service (by node_id + name)
- `POST /api/agent-workspaces/{id}/smoke-test` — run a structural reachability smoke test + store the health summary
- `GET /api/agent-workspaces/{id}/status` — current health summary + leg counts
- `GET /api/agent-workspaces/{id}/access-graph` — workspace → service → node graph for the GUI

## Customer environments

Represent customer VPC/on-prem environments and their gateways.

- `POST /api/customer-environments` — represent a customer VPC/on-prem environment
- `GET /api/customer-environments` — list the caller org's customer environments
- `GET /api/customer-environments/{id}` — customer environment detail
- `PATCH /api/customer-environments/{id}` — update a customer environment (name, customer, type, region)
- `DELETE /api/customer-environments/{id}` — delete a customer environment
- `POST /api/customer-environments/{id}/gateways` — attach a gateway node to the environment
- `DELETE /api/customer-environments/{id}/gateways/{nodeID}` — detach a gateway node from the environment
- `POST /api/customer-environments/{id}/services` — attach a deployed service (node + name) to the environment
- `DELETE /api/customer-environments/{id}/services` — detach a service (by node_id + name) from the environment
- `POST /api/customer-environments/{id}/preflight` — run the trust-boundary checklist + readiness check → health
- `POST /api/customer-environments/{id}/trust-brief` — set the manual trust brief (markdown)
- `GET /api/customer-environments/{id}/trust-brief` — get the manual trust brief (markdown)

## Delivery projects

AI-SI delivery tracking: checklists, resources, handoff.

- `POST /api/delivery-projects` — create an AI-SI delivery project (seeds the default checklist)
- `GET /api/delivery-projects` — list the caller org's delivery projects
- `GET /api/delivery-projects/{id}` — delivery project detail
- `PATCH /api/delivery-projects/{id}` — update a delivery project (name, stage, owner, due date)
- `DELETE /api/delivery-projects/{id}` — delete a delivery project
- `POST /api/delivery-projects/{id}/resources` — link a resource (demo_room/agent_workspace/gpu_workspace/customer_environment)
- `DELETE /api/delivery-projects/{id}/resources/{type}/{resourceID}` — unlink a resource by type + id
- `POST /api/delivery-projects/{id}/checklist/{key}/complete` — mark a checklist item done (optional evidence_ref)
- `POST /api/delivery-projects/{id}/handoff` — set the handoff document (markdown)
- `GET /api/delivery-projects/{id}/handoff` — get the handoff document (markdown)

## Billing & usage

Metered usage and subscription checkout.

- `GET /api/usage` — metering readout (totals + events)
- `POST /api/checkout` — start a Stripe Checkout to subscribe a network → hosted checkout URL
- `POST /api/billing/toss/subscribe` — subscribe a network via Toss recurring billing (issue billing key + charge → active)
- `GET /api/billing/pricing` — effective plan prices (store override or env seed) + currency

