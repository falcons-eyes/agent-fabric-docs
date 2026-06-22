---
title: falcon CLI reference
---

Every command and flag, generated from the cobra command tree.

### `falcon`

FalconEyes — your agents, your devices, your cloud. One private network.

falcon is the builder CLI for FalconEyes: managed trust and connectivity
for customer-owned AI and edge systems. Build the AI. We make it reachable.

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

Persist an externally managed model server in Falcon's local runtime state.

Attach is the preferred MVP path for macOS Apple Silicon, Windows, WSL2, native Ollama,
vLLM-Metal, or any OpenAI-compatible server you started yourself. Falcon verifies the
endpoint and records enough metadata for smoke tests, loop sessions, Local Console, and
optional mesh service registration.

```
falcon agent attach [name] [flags]
```

Examples:

```bash
# Attach native Ollama running on the default localhost port.
falcon agent attach mac-ollama \
  --url http://127.0.0.1:11434/v1 \
  --model llama3.2:latest

# Attach an OpenAI-compatible vLLM endpoint.
falcon agent attach existing-vllm \
  --url http://127.0.0.1:18000/v1 \
  --model qwen2.5-0.5b

# Attach and register the LLM service on the current joined mesh node.
falcon agent attach gpu-vllm \
  --url http://127.0.0.1:18000/v1 \
  --model qwen2.5-0.5b \
  --register
```

| flag | default | description |
|---|---|---|
| `--health-url` | `—` | optional health URL (default: <url>/models) |
| `--model` | `—` | served model name |
| `--register` | `false` | register the attached llm service on the current mesh node |
| `--url` | `—` | OpenAI-compatible localhost base URL, e.g. http://127.0.0.1:18000/v1 |

### `falcon agent discover`

Discover reachable localhost OpenAI-compatible model endpoints

Probe common localhost model-server ports without starting or modifying anything.

Discovery checks native Ollama and OpenAI-compatible endpoints such as vLLM. When a server
is reachable, Falcon prints the default model and an attach command you can copy. Unreachable
targets are hidden by default; use --all while debugging a local setup.

```
falcon agent discover [flags]
```

Examples:

```bash
# Show reachable model servers and suggested attach commands.
falcon agent discover

# Include failed probe targets to debug ports or server startup.
falcon agent discover --all

# Emit machine-readable discovery results.
falcon agent discover --json
```

| flag | default | description |
|---|---|---|
| `--all` | `false` | include unreachable probe targets |
| `--json` | `false` | print JSON |
| `--timeout` | `5s` | discovery timeout |

### `falcon agent doctor`

Run local runtime preflight checks

Check whether this host can run Falcon-managed local AI runtimes.

Linux hosts are checked for Docker, NVIDIA tooling, and GPU visibility for managed Docker
profiles. macOS Apple Silicon and Windows are attach-first in the MVP, so doctor points you
toward native local servers instead of reporting missing NVIDIA tooling as a hard failure.

```
falcon agent doctor
```

Examples:

```bash
# Check the current host before starting managed profiles.
falcon agent doctor

# macOS/Windows next step after doctor:
falcon agent discover
```

### `falcon agent logs`

Show logs for a Falcon-managed Docker runtime

Read recent Docker logs for a Falcon-managed runtime.

Logs are available for managed Docker profiles. For attached native endpoints, use the
runtime's own logging mechanism, such as the Ollama app, systemd, Docker, or your terminal.

```
falcon agent logs [name] [flags]
```

Examples:

```bash
# Show the last 120 log lines.
falcon agent logs dev-vllm

# Show more lines while debugging model load or readiness.
falcon agent logs dev-vllm --tail 500
```

| flag | default | description |
|---|---|---|
| `--tail` | `120` | number of log lines |

### `falcon agent loop`

Run or resume a local long-running agent loop

Run a session-backed local loop against an attached or managed runtime.

The loop is coordinated by aflocal, so start aflocal before running this command. Falcon
records each step as a local event and checkpoint, polls for cancellation, retries transient
step failures with backoff, and can compact/redact older local context. Prompts and outputs
stay in the local session store under ~/.falcon; they are not sent to the Falcon cloud.

```
falcon agent loop [runtime] [flags]
```

Examples:

```bash
# Terminal 1: start the Local Console backend.
aflocal

# Terminal 2: run three local loop steps.
falcon agent loop mac-ollama \
  --steps 3 \
  --prompt "Continue the local maintenance task and report concise progress." \
  --redact

# Resume the same session from its last loop-step checkpoint.
falcon agent loop mac-ollama --session sess_abc123 --steps 3

# Use a non-default aflocal URL, useful in tests or multiple local instances.
falcon agent loop mac-ollama --local-url http://127.0.0.1:13210 --steps 1 --json
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

Inspect and control sessions stored by the Local Agent Stack.

Sessions contain local-only events and checkpoints from smoke tests, loop runs, and future
agent/tool workflows. Use these commands to observe progress, follow live updates, cancel a
running loop, compact old context, or collect JSON for a local UI or script.

```
falcon agent session
```

Examples:

```bash
falcon agent session list
falcon agent session show sess_abc123
falcon agent session follow sess_abc123
falcon agent session cancel sess_abc123
falcon agent session compact sess_abc123 --redact-events --redact-checkpoints
```

### `falcon agent session cancel`

Cancel a local agent session

Mark a local session as cancelled.

Running loops poll the session status before each step and during retry backoff, so cancel is
observed without killing aflocal. A cancelled session is intentionally not reused; create a
new session or resume one that is not cancelled.

```
falcon agent session cancel [session-id] [flags]
```

Examples:

```bash
# Cancel an in-progress local loop.
falcon agent session cancel sess_abc123

# JSON output for automation.
falcon agent session cancel sess_abc123 --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | print JSON |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |

### `falcon agent session compact`

Compact local session context

Create a local compaction checkpoint and optionally redact older local payloads.

Compaction keeps recent events visible and records a summary checkpoint. With redaction
flags, older event contents and checkpoint states are replaced locally. This helps long-running
agent sessions stay inspectable without leaving all prompts and outputs in the visible tail.

```
falcon agent session compact [session-id] [flags]
```

Examples:

```bash
# Add a summary checkpoint but keep payloads visible.
falcon agent session compact sess_abc123 \
  --summary "Completed environment setup; next step is validation"

# Keep the latest 20 events and redact older event/checkpoint payloads.
falcon agent session compact sess_abc123 \
  --summary "Compacted completed setup work" \
  --keep-last-events 20 \
  --redact-events \
  --redact-checkpoints
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

Open the local session SSE stream and print live updates.

Follow first replays stored session, event, and checkpoint frames, then keeps the connection
open for new updates. It is useful while another terminal runs falcon agent loop. Stop it
with Ctrl-C.

```
falcon agent session follow [session-id] [flags]
```

Examples:

```bash
# Terminal 1: watch a session.
falcon agent session follow sess_abc123

# Terminal 2: resume work and watch updates appear in terminal 1.
falcon agent loop mac-ollama --session sess_abc123 --steps 5
```

| flag | default | description |
|---|---|---|
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |

### `falcon agent session list`

List local agent sessions

List sessions stored by aflocal under ~/.falcon/sessions.

The table shows status, runtime, model, event count, checkpoint count, update time, and
title. Use the session id with show, follow, cancel, compact, or agent loop --session.

```
falcon agent session list [flags]
```

Examples:

```bash
# Human-readable table.
falcon agent session list

# JSON for scripts or a local UI.
falcon agent session list --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | print JSON |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |

### `falcon agent session show`

Show a local agent session

Show session metadata plus recent events and checkpoints.

Use --tail to control how many recent events and checkpoints are printed. Use --json when
you need full event metadata, checkpoint state, or exact timestamps for debugging.

```
falcon agent session show [session-id] [flags]
```

Examples:

```bash
# Show the default recent event/checkpoint tail.
falcon agent session show sess_abc123

# Show more local history.
falcon agent session show sess_abc123 --tail 50

# Dump full structured detail.
falcon agent session show sess_abc123 --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | print JSON |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |
| `--tail` | `10` | events/checkpoints to show |

### `falcon agent smoke`

Run workload smoke and optional model-server capability checks

Verify that an attached or managed runtime is usable for local agent workflows.

Required checks cover streaming, multi-turn recall, local memory injection, and durable
loop checkpoint behavior. Optional capability checks record support for /v1/models, JSON
mode, tool/function calling, embeddings, and /v1/responses without failing the command when
a model server simply does not implement an optional feature.

```
falcon agent smoke [name] [flags]
```

Examples:

```bash
# Run the default smoke suite against an attached Ollama runtime.
falcon agent smoke mac-ollama

# Run more durable loop iterations.
falcon agent smoke dev-vllm --loops 5 --timeout 5m

# A good operator flow after smoke passes:
falcon agent loop dev-vllm --steps 3
```

| flag | default | description |
|---|---|---|
| `--loops` | `3` | durable loop iterations |
| `--timeout` | `3m0s` | smoke timeout |

### `falcon agent start`

Start a known local AI runtime profile

Start a known, audited local runtime profile. MVP managed start is Linux/NVIDIA Docker-first:
vllm-docker and ollama-docker. On macOS Apple Silicon or Windows, run a native local server
(Ollama, MLX/vLLM-Metal, WSL2, etc.) and attach it. Falcon does not vendor model servers or weights.

Use start when Falcon should own the Docker container lifecycle on this host. Use attach when
a model server is already running or when the platform is not Linux/NVIDIA Docker.

```
falcon agent start [flags]
```

Examples:

```bash
# Start a vLLM Docker profile on a Linux/NVIDIA host.
falcon agent start --runtime vllm-docker --name dev-vllm

# Start vLLM with an explicit Hugging Face model and served OpenAI model name.
falcon agent start \
  --runtime vllm-docker \
  --name qwen-dev \
  --model Qwen/Qwen2.5-0.5B-Instruct \
  --served-model qwen2.5-0.5b \
  --port 18000

# Start Ollama in Docker and register the resulting LLM service on the mesh.
falcon agent start --runtime ollama-docker --name dev-ollama --register
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

List runtime records stored under ~/.falcon/runtimes.

The table includes both Falcon-managed Docker profiles and externally managed endpoints
attached with falcon agent attach. This is the fastest way to confirm the runtime name to
use with smoke, loop, logs, stop, or Local Console API calls.

```
falcon agent status
```

Examples:

```bash
falcon agent status

# Typical next steps:
falcon agent smoke mac-ollama --loops 3
falcon agent loop mac-ollama --steps 3
```

### `falcon agent stop`

Stop a Falcon-managed runtime or detach an external endpoint

Stop a Falcon-managed Docker runtime, or remove an attached external endpoint from local state.

For attached native runtimes, Falcon does not stop the real server process; it only detaches
the runtime record. Stop Ollama, vLLM, or other native servers with their own tools.

```
falcon agent stop [name]
```

Examples:

```bash
# Stop a Falcon-managed Docker profile.
falcon agent stop dev-vllm

# Detach a native/external endpoint from Falcon local state.
falcon agent stop mac-ollama
```

### `falcon doctor`

Diagnose local setup: config, identity, keystore, control plane, node

```
falcon doctor
```

### `falcon down`

Disconnect this machine from the fabric (keeps your login + identity)

```
falcon down
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

### `falcon ip`

Print this node's overlay IP (or another node's with --name)

```
falcon ip [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |
| `--name` | `—` | print a specific node's overlay IP |

### `falcon join`

Join this machine to a network as a node

Enroll this device: generate a WireGuard keypair, register the public
key, receive an overlay IP, and fetch the signed peer map. The private
key stays on this machine — the control plane never sees it.

```
falcon join [flags]
```

| flag | default | description |
|---|---|---|
| `--name` | `—` | node name (default: hostname) |
| `--network` | `—` | network id to join (default: current network) |

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

Authenticate to FalconEyes.

With no flags, runs the browser device flow (RFC 8628): the CLI shows a
code you approve at the control plane's app — works on servers/containers
with no local browser.

--token <jwt>       store a real Cognito ID token (AWS mode), no device flow.
--org <id>          dev mode: store a 'dev:<org>' token, no AWS needed.
--control-url <url> set & persist the control plane URL.

Note: the AF_CONTROL_URL env var, if set, overrides the saved URL for
the current shell — unset it to fall back to the saved value.

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

### `falcon names`

List private node/service names from the signed netmap

```
falcon names [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |

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

### `falcon serve`

Publish a local service to your private network

Publish a locally-running service — an LLM/MCP/A2A endpoint or a TCP port —
into your private mesh as an addressable service. The control plane brokers
reachability and capabilities; your traffic stays peer-to-peer (it never sees
prompts or outputs).

Friendly framing of `falcon service add`. Kinds: llm, mcp, a2a, router,
endpoint, tcp.

Example:
  falcon serve http://127.0.0.1:11434 --name mac-ollama --kind llm

```
falcon serve <local-addr> [flags]
```

| flag | default | description |
|---|---|---|
| `--kind` | `llm` | service kind: llm|mcp|a2a|router|endpoint|tcp |
| `--name` | `—` | service name (required), e.g. mac-ollama |
| `--scope` | `—` | capability scope required to reach it |

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

### `falcon up`

Connect this machine to your private network (login + join + readiness)

The first-run command. Ensures you're signed in (device flow), joins this
machine to a network, and reports readiness. `up` ≠ `login` (just auth).
Bring up the WireGuard tunnel with the node agent (afd), which `up` guides.

```
falcon up [flags]
```

| flag | default | description |
|---|---|---|
| `--create-network` | `false` | create the network if it doesn't exist |
| `--json` | `false` | also print a JSON result line |
| `--name` | `—` | node name (default: hostname) |
| `--network` | `—` | network name or id to join |

### `falcon version`

Print the falcon CLI version

```
falcon version
```

### `falcon wait`

Wait until this node is ready (ip, netmap, control)

Exit 0 once the requested readiness signals hold, else fail at --timeout.
Signals: ip (overlay IP assigned), netmap (signed map accepted), control
(control plane reachable). Default: ip,netmap.

```
falcon wait [flags]
```

| flag | default | description |
|---|---|---|
| `--for` | `[ip,netmap]` | signals to wait for: ip,netmap,control |
| `--timeout` | `30s` | maximum time to wait |

### `falcon whois`

Resolve an overlay IP or private name to its node/service

```
falcon whois <ip|private-name> [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |

