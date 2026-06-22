---
title: HTTP API reference
---

Routes served by `control` (`internal/api`). Auth: `none` (public), `org` (Cognito/dev OIDC bearer), `relay-secret` / `billing-secret` (service-to-service shared secret). A suspended network gets `402 Payment Required` on the billable routes.

| method | path | auth | summary |
|---|---|---|---|
| `GET` | `/healthz` | none | liveness probe |
| `POST` | `/svc/relay/usage` | relay-secret | relay egress report (idempotent on relay_id+session_id+sequence) |
| `POST` | `/svc/entitlement` | billing-secret | set a network's plan/entitlement (billing webhook) |
| `POST` | `/svc/stripe/webhook` | stripe-signature | Stripe subscription webhook → entitlement (cancel→suspend, reactivate→active) |
| `POST` | `/api/networks` | org | create a private network |
| `GET` | `/api/networks` | org | list the caller org's networks |
| `GET` | `/api/networks/{id}/billing` | org | network subscription status (plan, entitlement, renews_at) — no payment credential |
| `POST` | `/api/enroll` | org | enroll a node (device proof-of-possession optional); 402 if suspended |
| `GET` | `/api/nodes` | org | list nodes (?network_id=) |
| `DELETE` | `/api/nodes/{id}` | org | delete a node (revoke membership) |
| `POST` | `/api/nodes/{id}/heartbeat` | org | node liveness + reachability candidates |
| `POST` | `/api/nodes/{id}/services` | org | attach a private service (mcp/a2a/llm/…) |
| `GET` | `/api/netmap/{id}` | org | signed network map (peers + entitlement envelope) |
| `GET` | `/api/control-key` | org | Ed25519 netmap verify key (+ key_id) |
| `GET` | `/api/relay/{id}` | org | relay endpoint + signed admission ticket; 402 if suspended |
| `POST` | `/api/capabilities` | org | issue a macaroon-style capability token |
| `POST` | `/api/gateway/resolve` | org | resolve a service via a capability; 402 if suspended |
| `GET` | `/api/usage` | org | metering readout (totals + events) |
| `POST` | `/api/checkout` | org | start a Stripe Checkout to subscribe a network → hosted checkout URL |
| `POST` | `/api/billing/toss/subscribe` | org | subscribe a network via Toss recurring billing (issue billing key + charge → active) |
| `POST` | `/svc/toss/webhook` | toss-requery | Toss payment webhook → entitlement (re-queries the payment to confirm) |
