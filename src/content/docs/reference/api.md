---
title: HTTP API reference
---

Routes served by `control` (`internal/api`). Auth: `none` (public) or `org` (Cognito/dev OIDC bearer). A suspended network gets `402 Payment Required` on the billable routes. (Internal service-to-service and webhook routes are not part of the public API and are not listed.)

| method | path | auth | summary |
|---|---|---|---|
| `GET` | `/healthz` | none | liveness probe |
| `GET` | `/api/workspace` | org | workspace (org) profile — name, plan, owner |
| `POST` | `/api/workspace/bootstrap` | org | first-run setup: create the org + a Default network (idempotent, no-op once bootstrapped) |
| `PATCH` | `/api/workspace` | org | rename the workspace (label change only) |
| `GET` | `/api/workspace/members` | org | workspace roster — owner + invitations |
| `GET` | `/api/workspace/invitations` | org | list the caller org's invitations |
| `POST` | `/api/workspace/invitations` | org | invite a teammate by email + role (admin|member) |
| `POST` | `/api/workspace/invitations/{id}/accept` | org | accept an invitation addressed to your email — join the inviting org |
| `DELETE` | `/api/workspace/invitations/{id}` | org | revoke an invitation |
| `POST` | `/api/networks` | org | create a private network |
| `GET` | `/api/networks` | org | list the caller org's networks |
| `PATCH` | `/api/networks/{id}` | org | rename a network (label change only) |
| `DELETE` | `/api/networks/{id}` | org | delete an empty network (409 if nodes remain) |
| `GET` | `/api/networks/{id}/billing` | org | network subscription status (plan, entitlement, renews_at) — no payment credential |
| `POST` | `/api/enroll` | org | enroll a node (device proof-of-possession optional); 402 if suspended |
| `GET` | `/api/nodes` | org | list nodes (?network_id=) |
| `DELETE` | `/api/nodes/{id}` | org | delete a node (revoke membership) |
| `PATCH` | `/api/nodes/{id}` | org | rename a node (keeps id + overlay IP) |
| `POST` | `/api/nodes/{id}/revoke` | org | revoke a node's device identity (blocks re-enroll) + remove it |
| `POST` | `/api/nodes/{id}/heartbeat` | org | node liveness + reachability candidates |
| `POST` | `/api/nodes/{id}/services` | org | attach a private service (mcp/a2a/llm/…) |
| `DELETE` | `/api/nodes/{id}/services/{name}` | org | remove a published service from a node |
| `POST` | `/api/nodes/{id}/jobs` | org | enqueue an allow-listed desired-state job for a node |
| `GET` | `/api/nodes/{id}/jobs` | org | list a node's desired-state jobs (?status=pending for the node poll) |
| `POST` | `/api/jobs/{id}/status` | org | node reports a job's reconciled state (applied|failed|rejected) |
| `GET` | `/api/netmap/{id}` | org | signed network map (peers + entitlement envelope) |
| `GET` | `/api/control-key` | org | Ed25519 netmap verify key (+ key_id) |
| `GET` | `/api/relay/{id}` | org | relay endpoint + signed admission ticket; 402 if suspended |
| `POST` | `/api/capabilities` | org | issue a macaroon-style capability token |
| `POST` | `/api/gateway/resolve` | org | resolve a service via a capability; 402 if suspended |
| `POST` | `/api/console/access` | org | request remote Local Console access → node-scoped capability (403 if no ACL grant) |
| `POST` | `/api/console/verify` | org | node forwarder: verify a console capability + re-check the ACL (fail-closed) |
| `POST` | `/api/console/grants` | org | grant a subject console access to a node (zero-trust ACL) |
| `GET` | `/api/console/grants` | org | list a network's console ACL grants (?network_id=) |
| `DELETE` | `/api/console/grants` | org | revoke a console ACL grant |
| `GET` | `/api/usage` | org | metering readout (totals + events) |
| `POST` | `/api/checkout` | org | start a Stripe Checkout to subscribe a network → hosted checkout URL |
| `POST` | `/api/billing/toss/subscribe` | org | subscribe a network via Toss recurring billing (issue billing key + charge → active) |
| `POST` | `/device/code` | none | device-flow: request a device + user code (RFC 8628) |
| `POST` | `/device/token` | none | device-flow: poll for tokens (grant_type=device_code|refresh_token) |
| `POST` | `/api/device/approve` | org | approve a device-flow user code (binds it to the caller) |
| `POST` | `/api/device/deny` | org | deny a device-flow user code |
| `GET` | `/api/device/pending` | org | device-flow grant awaiting approval (client name + request IP) |
| `GET` | `/api/device/sessions` | org | list the caller's active CLI/device sessions |
| `DELETE` | `/api/device/sessions/{id}` | org | revoke a device session |
