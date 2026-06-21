---
title: falcon CLI reference
---

Every command and flag, generated from the cobra command tree.

### `falcon`

FalconEyes — your agents, your devices, your cloud. One private network.

```
falcon
```

### `falcon agent`

Agent runtime recipes and local supervisor

```
falcon agent
```

### `falcon agent add`

Register an agent runtime recipe

```
falcon agent add [name]
```

### `falcon agent attach`

Attach an existing localhost OpenAI-compatible endpoint

```
falcon agent attach [name] [flags]
```

| flag | default | description |
|---|---|---|
| `--health-url` | `—` | optional health URL (default: <url>/models) |
| `--model` | `—` | served model name |
| `--register` | `false` | register the attached llm service on the current mesh node |
| `--url` | `—` | OpenAI-compatible localhost base URL, e.g. http://127.0.0.1:18000/v1 |

### `falcon agent discover`

Discover reachable localhost OpenAI-compatible model endpoints

```
falcon agent discover [flags]
```

| flag | default | description |
|---|---|---|
| `--all` | `false` | include unreachable probe targets |
| `--json` | `false` | print JSON |
| `--timeout` | `5s` | discovery timeout |

### `falcon agent doctor`

Run local runtime preflight checks

```
falcon agent doctor
```

### `falcon agent logs`

Show logs for a Falcon-managed Docker runtime

```
falcon agent logs [name] [flags]
```

| flag | default | description |
|---|---|---|
| `--tail` | `120` | number of log lines |

### `falcon agent loop`

Run or resume a local long-running agent loop

```
falcon agent loop [runtime] [flags]
```

| flag | default | description |
|---|---|---|
| `--compact-every` | `5` | compact every N completed steps |
| `--json` | `false` | print JSON |
| `--keep-last-events` | `20` | events to keep visible during compaction |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |
| `--max-retries` | `2` | retries per step |
| `--prompt` | `—` | loop goal prompt |
| `--redact` | `false` | redact compacted local event/checkpoint payloads |
| `--retry-backoff` | `750ms` | base retry backoff |
| `--session` | `—` | existing local session id to resume |
| `--steps` | `5` | number of loop steps to run |
| `--timeout` | `10m0s` | overall loop timeout |
| `--title` | `—` | new session title |

### `falcon agent session`

Inspect and control local agent sessions

```
falcon agent session
```

### `falcon agent session cancel`

Cancel a local agent session

```
falcon agent session cancel [session-id] [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | print JSON |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |

### `falcon agent session compact`

Compact local session context

```
falcon agent session compact [session-id] [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | print JSON |
| `--keep-last-events` | `20` | events to keep visible |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |
| `--reason` | `manual compaction` | redaction reason |
| `--redact-checkpoints` | `false` | redact checkpoint states |
| `--redact-events` | `false` | redact compacted event contents |
| `--summary` | `Manual local compaction` | summary stored in the compaction checkpoint |

### `falcon agent session follow`

Follow live local session updates

```
falcon agent session follow [session-id] [flags]
```

| flag | default | description |
|---|---|---|
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |

### `falcon agent session list`

List local agent sessions

```
falcon agent session list [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | print JSON |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |

### `falcon agent session show`

Show a local agent session

```
falcon agent session show [session-id] [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | print JSON |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |
| `--tail` | `10` | events/checkpoints to show |

### `falcon agent smoke`

Run workload smoke and optional model-server capability checks

```
falcon agent smoke [name] [flags]
```

| flag | default | description |
|---|---|---|
| `--loops` | `3` | durable loop iterations |
| `--timeout` | `3m0s` | smoke timeout |

### `falcon agent start`

Start a known local AI runtime profile

```
falcon agent start [flags]
```

| flag | default | description |
|---|---|---|
| `--model` | `—` | model to load or pull (default depends on runtime) |
| `--name` | `—` | local runtime name |
| `--port` | `0` | localhost port (default depends on runtime) |
| `--pull` | `true` | pull the model when the runtime supports it |
| `--register` | `false` | register the resulting llm service on the current mesh node |
| `--runtime` | `vllm-docker` | runtime profile: vllm-docker|ollama-docker (Linux/NVIDIA Docker) |
| `--served-model` | `—` | OpenAI-compatible served model name (vLLM) |
| `--wait` | `4m0s` | readiness timeout |

### `falcon agent status`

Show local Falcon-managed or attached runtimes

```
falcon agent status
```

### `falcon agent stop`

Stop a Falcon-managed runtime or detach an external endpoint

```
falcon agent stop [name]
```

### `falcon doctor`

Diagnose local setup: config, identity, keystore, control plane, node

```
falcon doctor
```

### `falcon endpoint`

OpenAI-compatible endpoint recipes

```
falcon endpoint
```

### `falcon endpoint add`

OpenAI-compatible endpoint recipes

```
falcon endpoint add [name]
```

### `falcon gateway`

Manage customer-owned gateways

```
falcon gateway
```

### `falcon gateway deploy`

Deploy a customer-owned gateway into your own cloud

```
falcon gateway deploy [flags]
```

| flag | default | description |
|---|---|---|
| `--aws` | `false` | deploy into AWS (EC2/VPC) using local aws credentials |

### `falcon grant`

Mint a capability token for a private resource (e.g. mcp://local-files)

```
falcon grant [resource] [flags]
```

| flag | default | description |
|---|---|---|
| `--action` | `read` | granted action |
| `--ttl` | `10m0s` | token lifetime |

### `falcon join`

Join this machine to a network as a node

```
falcon join [flags]
```

| flag | default | description |
|---|---|---|
| `--name` | `—` | node name (default: hostname) |

### `falcon llm`

Local LLM runtime recipes

```
falcon llm
```

### `falcon llm init`

Local LLM runtime recipes

```
falcon llm init [name]
```

### `falcon login`

Authenticate to FalconEyes (org/human identity)

```
falcon login [flags]
```

| flag | default | description |
|---|---|---|
| `--control-url` | `—` | control plane URL to set & persist |
| `--org` | `dev` | organization id (dev mode) |
| `--token` | `—` | raw Cognito ID token (AWS mode) |

### `falcon logout`

Clear the local FalconEyes session

```
falcon logout
```

### `falcon network`

Manage private overlay networks

```
falcon network
```

### `falcon network create`

Create a new private network

```
falcon network create [name]
```

### `falcon network list`

List your networks

```
falcon network list
```

### `falcon nodes`

List nodes on the current network

```
falcon nodes
```

### `falcon resolve`

Resolve a private service through the gateway using a capability

```
falcon resolve [service] [flags]
```

| flag | default | description |
|---|---|---|
| `--action` | `read` | requested action |
| `--cap` | `—` | capability token from `falcon grant` |

### `falcon router`

Model router recipes

```
falcon router
```

### `falcon router init`

Model router recipes

```
falcon router init [name]
```

### `falcon service`

Register private services on the mesh

```
falcon service
```

### `falcon service add`

Register a private service (mcp://… or a2a://…)

```
falcon service add [uri]
```

### `falcon status`

Show this node's mesh status

```
falcon status
```

