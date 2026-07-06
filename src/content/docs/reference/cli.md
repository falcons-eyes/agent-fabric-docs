---
title: falcon CLI reference
---

Every command and flag, generated from the cobra command tree. Commands are grouped the same way `falcon --help` groups them.

### `falcon`

FalconEyes — your agents, your devices, your cloud. One private network.

falcon is the builder CLI for FalconEyes: managed trust and connectivity
for customer-owned AI and edge systems. Build the AI. We make it reachable.

New here? Run `falcon quickstart` — it connects this machine, publishes a local
AI model, and shows how to call it privately, in one flow. The natural sequence:
  login → up → serve → grant → try / resolve → status / doctor

```
falcon
```

| flag | default | description |
|---|---|---|
| `--verbose` | `false` | verbose debug logging |

## Get started

### `falcon quickstart`

Connect this machine, publish a local AI model, and show how to call it — in one flow

The whole product in one command. quickstart:
  1. checks you're signed in,
  2. puts this machine on your private mesh (enrolls it),
  3. finds a local model server (Ollama, vLLM, …),
  4. publishes it as a private, capability-gated service,
  5. shows the two commands to call it from any other machine.

No public port is opened. Re-run it any time — it's idempotent.

```
falcon quickstart
```

Examples:

```bash
falcon quickstart
```

### `falcon status`

Show this node's mesh status (host+mesh health snapshot; --json for agents)

```
falcon status [flags]
```

Examples:

```bash
falcon status
falcon status --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | emit the snapshot as a structured JSON digest (for agents/automation) |

### `falcon up`

Connect this machine to your private network (login + join + readiness)

The first-run command. Ensures you're signed in (device flow), joins this
machine to a network, and reports readiness. `up` ≠ `login` (just auth).
Bring up the WireGuard tunnel with the node agent (afd), which `up` guides.

```
falcon up [flags]
```

Examples:

```bash
falcon up
falcon up --network home --name laptop
sudo -E falcon up   # also brings the encrypted tunnel up
```

| flag | default | description |
|---|---|---|
| `--create-network` | `false` | create the network if it doesn't exist |
| `--json` | `false` | also print a JSON result line |
| `--name` | `—` | node name (default: hostname) |
| `--network` | `—` | network name or id to join |

## Your private network

### `falcon down`

Disconnect this machine from the fabric (keeps your login + identity)

```
falcon down
```

### `falcon grant`

Mint a capability token for a private resource (e.g. mcp://local-files)

Mint a short-lived, scoped capability token that lets someone reach one private
resource through the gateway — nothing else, and only until it expires. Give the
token to a teammate or paste it into `falcon resolve`. Revoke reach by letting it
expire (default 10m) rather than reconfiguring the service.

```
falcon grant [resource] [flags]
```

Examples:

```bash
falcon grant mcp://local-files --action read --ttl 30m
```

| flag | default | description |
|---|---|---|
| `--action` | `read` | granted action |
| `--json` | `false` | JSON output |
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

### `falcon names`

List private node/service names from the signed netmap

```
falcon names [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |

### `falcon ping`

Ping a peer over the overlay and show the path (direct/relay)

```
falcon ping [name] [flags]
```

| flag | default | description |
|---|---|---|
| `--network` | `—` | network the peer is on (name or id; default: current) |

### `falcon resolve`

Resolve a private service through the gateway using a capability

Exchange a capability token (from `falcon grant`) for the live coordinates of a
private service — the node it runs on and the address to reach it over the mesh.
The gateway enforces the capability, so a resolve without a valid token is refused.

```
falcon resolve [service] [flags]
```

Examples:

```bash
falcon resolve local-files --action read --cap <token>
```

| flag | default | description |
|---|---|---|
| `--action` | `read` | requested action |
| `--cap` | `—` | capability token from `falcon grant` |
| `--json` | `false` | JSON output |

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

Manage private services on the mesh

```
falcon service
```

### `falcon service add`

Register a private service (mcp://… or a2a://…)

```
falcon service add [uri]
```

### `falcon service inspect`

Show details for a private service (by name or private name)

```
falcon service inspect [name]
```

### `falcon service list`

List private services on the current network

```
falcon service list [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |

### `falcon service remove`

Remove a service published from this node

```
falcon service remove [name]
```

### `falcon service test`

Test reachability of a private service

```
falcon service test [name] [flags]
```

| flag | default | description |
|---|---|---|
| `--timeout` | `3s` | dial timeout |

### `falcon try`

Prove a published service works — mint access, call it, show the gate

Show the result, not just the setup. `try` mints a short-lived capability for
a service you published, has the control plane's gateway authorize it, proves the
same request is refused without a token, and — for a model — makes one real call so
you see it answer. It's the fastest way to see (and show) what your private AI now does.

```
falcon try <service> [flags]
```

Examples:

```bash
falcon try local-model
falcon try local-files --action read
```

| flag | default | description |
|---|---|---|
| `--action` | `—` | capability action to request (default: the kind's action) |
| `--prompt` | `Reply in one short sentence: are you reachable over the private mesh?` | prompt to send a model service |

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

Resolve an overlay IP or private name to its node/service (defaults to this node)

```
falcon whois [ip|private-name] [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |

## AI agents

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

### `falcon agent introspect`

Run an A2A agent that answers this node's mesh status/doctor/connectivity to peers

Expose this node's deterministic mesh diagnostics to peer AGENTS over A2A. A peer
agent sends a message ("status" | "doctor" | "connectivity") and receives the same
JSON digest the CLI renders — no shell access to this node required.

Publish it on the mesh — in another terminal:
  falcon serve <addr> --kind a2a --name mesh-introspect
then a peer reaches it (capability-scoped) through the gateway.

```
falcon agent introspect [flags]
```

| flag | default | description |
|---|---|---|
| `--addr` | `127.0.0.1:7777` | loopback address to bind the A2A introspection agent |

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

### `falcon agent reach`

Measure the round-trip to an agent service over the mesh (MCP/A2A)

Time a real agent-protocol call to a private service — MCP tools/list or the A2A
agent card — through the authorizing gateway. Reports whether it answered, the
round-trip latency, what it exposes, and the live tunnel path (direct/relay).
Needs a capability (`falcon grant`) and a running local gateway (`falcon gateway proxy`).

```
falcon agent reach [service] [flags]
```

Examples:

```bash
falcon agent reach mesh-introspect --cap <token>
```

| flag | default | description |
|---|---|---|
| `--action` | `tools/list` | action to authorize (JSON-RPC method for MCP) |
| `--cap` | `—` | capability token from `falcon grant` |
| `--gateway` | `http://127.0.0.1:7777` | local gateway proxy URL |
| `--json` | `false` | JSON output |

### `falcon agent run`

Run a composed agent on a task (uses its model, instructions and tools)

Run one reason→act pass for an agent you composed in the Local Console: it uses the
agent's model runtime and instructions, and can call the MCP tools wired to it — the
tool calls are executed for it and fed back. Needs aflocal running. The agent is named
or referenced by id.

```
falcon agent run [agent] [flags]
```

Examples:

```bash
falcon agent run researcher --prompt "summarize today's local notes"
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |
| `--local-url` | `—` | Local Console URL (default: http://127.0.0.1:3210) |
| `--max-rounds` | `0` | max tool rounds (default: server default) |
| `--prompt` | `—` | the task for the agent |

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
falcon agent status [flags]
```

Examples:

```bash
falcon agent status

# Typical next steps:
falcon agent smoke mac-ollama --loops 3
falcon agent loop mac-ollama --steps 3
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | print JSON |

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

### `falcon console`

Open a remote node's Local Console; manage console access (ACL)

```
falcon console
```

### `falcon console grant`

Grant a subject access to a node's Local Console (zero-trust ACL)

Author an ACL grant: <subject> (the grantee's identity) may open <node>'s
console. Use the node name or id, or "*" for every node in the network.
Without a grant, remote console access is denied (default-deny).

```
falcon console grant [subject] [node] [flags]
```

| flag | default | description |
|---|---|---|
| `--ttl` | `0s` | grant expiry (e.g. 24h; 0 = no expiry) |

### `falcon console grants`

List console access grants (the ACL) for the current network

```
falcon console grants
```

### `falcon console open`

Open a remote node's Local Console over the private network

```
falcon console open [node] [flags]
```

| flag | default | description |
|---|---|---|
| `--no-open` | `false` | print the URL without opening a browser |

### `falcon console revoke`

Revoke a subject's console access to a node

```
falcon console revoke [subject] [node]
```

### `falcon models`

Find and size local-runnable models (Hugging Face catalog)

```
falcon models
```

### `falcon models pull`

Pull the right quant for your GPU via Ollama, then publish it privately

One command from a Hugging Face model id to a running, private service:
we pick the quantization that fits your GPU (override with --quant), pull it via
Ollama's Hugging Face passthrough, then attach + publish it on your mesh. Needs a
running Ollama (`ollama serve`) and aflocal for the publish step.

```
falcon models pull [model-id] [flags]
```

Examples:

```bash
falcon models pull Qwen/Qwen2.5-7B-Instruct-GGUF
falcon models pull unsloth/gemma-2-9b-it-GGUF --quant Q4_K_M
```

| flag | default | description |
|---|---|---|
| `--name` | `—` | service name to publish as (default: derived from the model id) |
| `--no-publish` | `false` | pull only; don't attach/publish on the mesh |
| `--no-smoke` | `false` | skip the post-pull health check (also: AF_MODEL_SMOKE=off) |
| `--ollama-url` | `—` | Ollama base URL (default: http://127.0.0.1:11434 or $AF_OLLAMA_URL) |
| `--quant` | `—` | quantization to pull (default: the best that fits your GPU) |
| `--vram` | `0` | GPU VRAM in GB (default: auto-detect via aflocal) |
| `--yes` | `false` | pull even a low-trust model (skip the supply-chain gate) |

### `falcon models search`

Search trending models that run locally, sized to your GPU

```
falcon models search [query] [flags]
```

Examples:

```bash
falcon models search qwen2.5
falcon models search llama --sort recent --json
```

| flag | default | description |
|---|---|---|
| `--all` | `false` | include models without local (GGUF) weights |
| `--json` | `false` | JSON output |
| `--limit` | `15` | max results |
| `--sort` | `trending` | trending | likes | recent |
| `--vram` | `0` | GPU VRAM in GB to size against (default: auto-detect via aflocal) |

### `falcon models show`

Show a model's quantizations and which one we'd run on your GPU

```
falcon models show [model-id] [flags]
```

Examples:

```bash
falcon models show bartowski/Qwen2.5-7B-Instruct-GGUF
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |
| `--vram` | `0` | GPU VRAM in GB (default: auto-detect via aflocal) |

### `falcon web`

Open the Local Console for this machine

Open the localhost Local Console served by aflocal.

Start aflocal first if it is not already running. The Local Console is
loopback-only and manages this node's AI runtimes, sessions, hardware,
diagnostics, and private names.

```
falcon web [flags]
```

| flag | default | description |
|---|---|---|
| `--addr` | `127.0.0.1:3210` | Local Console listen address |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |
| `--no-open` | `false` | check and print the URL without opening a browser |

## Account

### `falcon login`

Authenticate to FalconEyes (org/human identity)

Authenticate to FalconEyes.

With no flags, runs the browser device flow (RFC 8628): the CLI shows a
code you approve at the control plane's app — works on servers/containers
with no local browser.

--token <jwt>       store a real Cognito ID token (AWS mode), no device flow.
--org <id>          dev mode: store a 'dev:<org>' token, no AWS needed.
--control-url <url> set & persist the control plane URL.

To switch control planes, log in with --control-url (it persists). The
AF_CONTROL_URL env var is a narrow override (e.g. the control plane moved
ports); it wins over the saved URL for the current shell, so a stale value
can point you at the wrong place — prefer --control-url and unset it when done.
Your session is bound to its control plane: it is never used against another.

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

Clear the local session (token + refresh). By default the device identity —
the WireGuard private key and machine-key seed — is KEPT so you can sign back
in without re-enrolling. Use --purge to also erase the device identity from
this machine (e.g. before handing it off); revoking the device in the console
is still the way to invalidate it server-side.

```
falcon logout [flags]
```

| flag | default | description |
|---|---|---|
| `--purge` | `false` | also erase the local device identity (WireGuard key + machine seed) |

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

### `falcon network delete`

Delete an empty network (by name or id)

Delete a network you own. The network must be empty — remove its nodes
first. This cannot be undone.

```
falcon network delete [network] [flags]
```

| flag | default | description |
|---|---|---|
| `--yes` | `false` | skip the confirmation prompt |

### `falcon network list`

List your networks

```
falcon network list [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |

### `falcon network prune`

Delete empty networks (no machines) — explicit cleanup, with confirmation

Find networks that have no machines and delete them, so stale networks
left over from testing don't pile up. Networks that still have machines are
never touched, and nothing is deleted without your confirmation (or --yes).
This never runs automatically — it's the manual counterpart to the 'idle'
state shown by `falcon network list`.

```
falcon network prune [flags]
```

| flag | default | description |
|---|---|---|
| `--yes` | `false` | skip the confirmation prompt |

### `falcon network rename`

Rename a network (by name or id)

```
falcon network rename [network] [new-name]
```

### `falcon node`

Manage nodes on the current network

```
falcon node
```

### `falcon node list`

List nodes on a network (default: current; --network for any you own)

```
falcon node list [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |
| `--network` | `—` | network name or id (default: the joined one) |

### `falcon node remove`

Remove a node from a network (revokes its access)

Revoke a node's membership. It loses access immediately; reconnect it later
with `falcon up`. Removing this machine's own node disconnects it. Use
--network to remove a node from a network you own without being joined to it
(e.g. clearing a stale registration after a local reset).

```
falcon node remove [name] [flags]
```

| flag | default | description |
|---|---|---|
| `--network` | `—` | network name or id (default: the joined one) |
| `--yes` | `false` | skip the confirmation prompt |

### `falcon node rename`

Rename a node (keeps its overlay IP)

```
falcon node rename [current-name] [new-name] [flags]
```

| flag | default | description |
|---|---|---|
| `--network` | `—` | network the node is on (name or id; default: current) |

### `falcon node revoke`

Permanently revoke a node's device identity (lost/stolen device)

Revoke removes the node AND blacklists its device (machine) identity, so a
lost or stolen device — whose holder still has the machine key — can NEVER
re-enroll in this org. Use `node remove` for a normal removal the device can
undo by reconnecting; revoke is permanent for that device key.

```
falcon node revoke [name] [flags]
```

| flag | default | description |
|---|---|---|
| `--network` | `—` | network the node is on (name or id; default: current) |
| `--yes` | `false` | skip confirmation |

### `falcon node show`

Show details for a node

```
falcon node show [name]
```

### `falcon nodes`

List nodes on the current network

```
falcon nodes
```

### `falcon usage`

Show this workspace's metered usage (relay egress, api, node-hours)

```
falcon usage [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | emit usage as JSON |

### `falcon whoami`

Show the current identity: workspace, plan, control plane, node

```
falcon whoami [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |

### `falcon workspace`

Manage your workspace: name, members, invitations

```
falcon workspace
```

### `falcon workspace invite`

Invite a teammate by email

Invite a teammate to the workspace. They appear as a pending member until
an accept flow lands. Role is member (default) or admin.

```
falcon workspace invite [email] [flags]
```

| flag | default | description |
|---|---|---|
| `--role` | `member` | member or admin |

### `falcon workspace members`

List workspace members and pending invitations

```
falcon workspace members
```

### `falcon workspace rename`

Rename the workspace

```
falcon workspace rename [name]
```

### `falcon workspace revoke`

Revoke a pending invitation

```
falcon workspace revoke [invitation-id] [flags]
```

| flag | default | description |
|---|---|---|
| `--yes` | `false` | skip the confirmation prompt |

### `falcon workspace show`

Show the current workspace (name, plan, owner)

```
falcon workspace show
```

## Diagnostics

### `falcon bugreport`

Generate a privacy-safe support bundle (no prompts, outputs, tokens, or keys)

Collect just enough metadata to debug join/runtime/connectivity issues —
version, OS/arch, control host, org/network/node ids, the signed netmap
generation/entitlement/peer+service counts, and the observe-engine diagnostics
(doctor/status/connectivity verdicts). It NEVER includes tokens, keys, prompts,
model outputs, or session content.

```
falcon bugreport [flags]
```

| flag | default | description |
|---|---|---|
| `--output` | `—` | write the bundle to a file instead of stdout |

### `falcon control-key`

Inspect or rotate the pinned control-plane verify key (trust anchor)

```
falcon control-key
```

### `falcon control-key repin`

Pin the key the control plane currently serves (after a legitimate rotation)

```
falcon control-key repin [flags]
```

| flag | default | description |
|---|---|---|
| `--yes` | `false` | skip the confirmation prompt (for automation) |

### `falcon control-key show`

Show the pinned control key and whether it matches the server

```
falcon control-key show
```

### `falcon doctor`

Diagnose local setup: config, identity, keystore, control plane, node (--json for agents)

```
falcon doctor [flags]
```

Examples:

```bash
falcon doctor
falcon doctor --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | emit the report as a structured JSON digest (for agents/automation) |

### `falcon host`

Deterministic host snapshot: os, cpu/load, memory, disk, network (--json for agents)

A deterministic host snapshot — OS/kernel, CPU + load average, memory, the root
filesystem, and up network interfaces — gathered from machine-readable sources.
An agent reads it in one call instead of running uname/df/ip/free across turns.

```
falcon host [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | emit the snapshot as a structured JSON digest (for agents/automation) |

### `falcon netcheck`

Diagnose mesh connectivity: control, netmap, relay, NAT, and per-peer path (--json for agents)

```
falcon netcheck [flags]
```

Examples:

```bash
falcon netcheck
falcon netcheck --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | emit the diagnosis as a structured JSON digest (for agents/automation) |

## Advanced

### `falcon agent-workspace`

Agent workspaces (agent + model + tool services)

```
falcon agent-workspace
```

### `falcon agent-workspace create`

Create an agent workspace

```
falcon agent-workspace create [flags]
```

| flag | default | description |
|---|---|---|
| `--name` | `—` | workspace name |
| `--network` | `—` | network id |
| `--purpose` | `—` | purpose, e.g. research |

### `falcon agent-workspace list`

List agent workspaces

```
falcon agent-workspace list
```

### `falcon agent-workspace smoke-test`

Run the structural smoke test

```
falcon agent-workspace smoke-test <workspace-id>
```

### `falcon customer-env`

Customer environments (VPC/on-prem)

```
falcon customer-env
```

### `falcon customer-env create`

Represent a customer environment

```
falcon customer-env create [flags]
```

| flag | default | description |
|---|---|---|
| `--customer` | `—` | customer name |
| `--name` | `—` | environment name |
| `--region` | `—` | region |
| `--type` | `aws_vpc` | environment type |

### `falcon customer-env list`

List customer environments

```
falcon customer-env list
```

### `falcon customer-env preflight`

Run the trust-boundary + readiness check

```
falcon customer-env preflight <env-id>
```

### `falcon delivery`

Delivery projects (AI-SI customer deliveries)

```
falcon delivery
```

### `falcon delivery handoff`

Export the handoff document (markdown)

```
falcon delivery handoff <project-id>
```

### `falcon delivery init`

Initialize a delivery project

```
falcon delivery init [flags]
```

| flag | default | description |
|---|---|---|
| `--customer` | `—` | customer name |
| `--name` | `—` | project name |
| `--stage` | `pilot` | stage: pilot|poc|production|closed |

### `falcon delivery list`

List delivery projects

```
falcon delivery list
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

Run the local agent-protocol gateway

```
falcon gateway
```

### `falcon gateway proxy`

Run the local gateway: forward authorized MCP/A2A calls over the mesh

```
falcon gateway proxy [flags]
```

| flag | default | description |
|---|---|---|
| `--listen` | `127.0.0.1:7777` | local listen address (loopback by default) |

### `falcon gpu-workspace`

Private GPU workspaces (team model endpoints)

```
falcon gpu-workspace
```

### `falcon gpu-workspace create`

Register a GPU node as a team model endpoint

```
falcon gpu-workspace create [flags]
```

| flag | default | description |
|---|---|---|
| `--name` | `—` | workspace name |
| `--node` | `—` | GPU node id |

### `falcon gpu-workspace detect`

Detect the node's GPU/runtime capabilities

```
falcon gpu-workspace detect <workspace-id>
```

### `falcon gpu-workspace list`

List GPU workspaces

```
falcon gpu-workspace list
```

### `falcon gpu-workspace publish`

Remotely publish a loopback model service on the GPU node (APPLY_RECIPE)

```
falcon gpu-workspace publish <workspace-id> [flags]
```

| flag | default | description |
|---|---|---|
| `--addr` | `—` | local address, e.g. 127.0.0.1:11434 (loopback only) |
| `--kind` | `llm` | model kind: llm|router|endpoint |
| `--name` | `—` | service name (dns-safe) |

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

### `falcon mcp`

Run a local MCP server exposing the mesh digests (status, connectivity, doctor, host) as tools

Expose falcon's deterministic mesh diagnostics to an LLM agent over MCP (stdio).

Tools:
  mesh_status        host+mesh health snapshot (node, control, entitlement, tunnel, relay, peers)
  mesh_connectivity  path diagnosis (control → netmap → relay → NAT → per-peer) with fix hints
  mesh_doctor        local setup + security posture (config, keystore, control key drift, MTU/CIDR)
  host_snapshot      deterministic host snapshot (OS, CPU/load, memory, disk, interfaces)

Add to an MCP client (e.g. Claude Code): {"command":"falcon","args":["mcp"]}

```
falcon mcp
```

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

## Maintenance

### `falcon update`

Update falcon (and the node agents) to the latest release

Download, verify (sha256) and replace the falcon CLI and its background
agents in place. Use --check to see what's available without installing.

```
falcon update [flags]
```

| flag | default | description |
|---|---|---|
| `--channel` | `stable` | release channel: stable, beta, or nightly |
| `--check` | `false` | only report whether an update is available |
| `--force` | `false` | reinstall even if already up to date |
| `--version` | `—` | install a specific version (e.g. v0.2.0) instead of the channel latest |

### `falcon version`

Print the falcon CLI version

```
falcon version
```

