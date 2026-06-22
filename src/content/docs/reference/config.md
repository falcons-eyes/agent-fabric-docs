---
title: Configuration (control plane)
---

Environment variables read by `control` (`internal/platform/config`).

| env var | default | description |
|---|---|---|
| `AF_PORT` | `8080` | HTTP API listen port |
| `AWS_REGION` | `us-east-1` | AWS region (Cognito / DynamoDB / KMS) |
| `AF_DEV_MODE` | `true` | in-memory store + dev resolver; set false for AWS/prod (fail-closed identity) |
| `AF_COGNITO_USER_POOL` | `—` | Cognito user pool id (required when AF_DEV_MODE=false) |
| `AF_COGNITO_CLIENT_ID` | `—` | Cognito app client id (token audience) |
| `AF_DYNAMO_TABLE` | `agent-fabric` | DynamoDB single-table name (AWS mode) |
| `AF_OVERLAY_CIDR` | `100.64.0.0/10` | overlay IP allocation range (IPAM) |
| `AF_DERP_REGIONS` | `us-east-1,us-west-2` | comma-separated relay regions for fallback |
| `AF_KMS_KEY_ID` | `—` | control CMK (alias/agent-fabric-control) used to seal keys |
| `AF_CAP_KEY` | `—` | capability HMAC key, plaintext (dev; empty → random per start) |
| `AF_CAP_KEY_ENC` | `—` | capability HMAC key, base64 KMS ciphertext (prod; wins over AF_CAP_KEY) |
| `AF_NETMAP_KEY` | `—` | Ed25519 netmap signing seed, hex (dev; empty → ephemeral) |
| `AF_NETMAP_KEY_ENC` | `—` | Ed25519 seed, base64 KMS ciphertext (prod; wins over AF_NETMAP_KEY) |
| `AF_RELAY_URL` | `—` | relay endpoint advertised to nodes (host:port); enables relay coordination |
| `AF_RELAY_SECRET` | `—` | shared HMAC secret with the relay (ticket signing + usage-report auth) |
| `AF_BILLING_SECRET` | `—` | shared secret authenticating POST /svc/entitlement (billing webhook) |
| `AF_STRIPE_WEBHOOK_SECRET` | `—` | Stripe webhook signing secret (whsec_…) for POST /svc/stripe/webhook → entitlement |
| `AF_STRIPE_API_KEY` | `—` | Stripe secret API key (sk_…) for creating Checkout sessions (POST /api/checkout) |
| `AF_STRIPE_PRICES` | `—` | plan→Stripe price-id map for checkout, e.g. pro=price_123,team=price_456 |
| `AF_TOSS_SECRET_KEY` | `—` | Toss Payments secret key (test_sk_…/live_sk_…) for recurring billing (POST /api/billing/toss/subscribe) |
| `AF_TOSS_PRICES` | `—` | plan→monthly KRW amount map for Toss, e.g. pro=29000,team=99000 |
| `AF_TOSS_WEBHOOK_SECRET` | `—` | Toss webhook security key (보안키) for POST /svc/toss/webhook |
| `AF_APP_BASE_URL` | `https://app.falconoon.com` | public app base URL for Checkout success/cancel redirects |
| `AF_CORS_ORIGINS` | `http://localhost:5173,http://127.0.0.1:5173,https://app.falconoon.com` | comma-separated browser origins allowed to call /api (the app dashboard); * = any |
| `AF_FREE_MAX_NODES` | `3` | free-tier node cap per network (enroll → 402 once exceeded; 0 = unlimited); a paid plan lifts it |
| `AF_FREE_MAX_NETWORKS` | `0` | free-tier network cap per org (createNetwork → 402 once exceeded; 0 = unlimited) |
| `AF_TRUSTED_PROXY_DEPTH` | `0` | trusted proxy hops in front of the control plane (e.g. CloudFront [+ App Runner]); >0 reads the source IP the outermost proxy recorded instead of the spoofable left-most X-Forwarded-For (anti-reflection for candidate validation); 0 = legacy left-most |
| `AF_TLS_CERT` | `—` | path to TLS cert (enables HTTPS for self-host) |
| `AF_TLS_KEY` | `—` | path to TLS key |
