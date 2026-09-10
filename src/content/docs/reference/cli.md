---
title: fabric CLI reference
---

Every command and flag, generated from the cobra command tree. Commands are grouped the same way `fabric --help` groups them.

### `fabric`

Agent-Fabric — your agents, your devices, your cloud. One private network.

fabric is the builder CLI for Agent-Fabric: managed trust and connectivity
for customer-owned AI and edge systems. Build the AI. We make it reachable.

New here? Run `fabric quickstart` — it connects this machine, publishes a local
AI model, and shows how to call it privately, in one flow. The natural sequence:
  login → up → serve → grant → try / resolve → status / doctor

```
fabric
```

| flag | default | description |
|---|---|---|
| `--verbose` | `false` | verbose debug logging |

## Get started

### `fabric quickstart`

Connect this machine, publish a local AI model, and show how to call it — in one flow

The whole product in one command. quickstart:
  1. checks you're signed in,
  2. puts this machine on your private mesh (enrolls it),
  3. finds a local model server (Ollama, vLLM, …),
  4. publishes it as a private, capability-gated service,
  5. shows the two commands to call it from any other machine.

No public port is opened. Re-run it any time — it's idempotent.

```
fabric quickstart
```

Examples:

```bash
fabric quickstart
```

### `fabric status`

Show this node's mesh status (host+mesh health snapshot; --json for agents)

```
fabric status [flags]
```

Examples:

```bash
fabric status
fabric status --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | emit the snapshot as a structured JSON digest (for agents/automation) |

### `fabric up`

Connect this machine to your private network (login + join + readiness)

The first-run command. Ensures you're signed in (device flow), joins this
machine to a network, and reports readiness. `up` ≠ `login` (just auth).
Bring up the WireGuard tunnel with the node agent (afd), which `up` guides.

```
fabric up [flags]
```

Examples:

```bash
fabric up
fabric up --network home --name laptop
sudo -E fabric up   # also brings the encrypted tunnel up
```

| flag | default | description |
|---|---|---|
| `--create-network` | `false` | create the network if it doesn't exist |
| `--json` | `false` | also print a JSON result line |
| `--name` | `—` | node name (default: hostname) |
| `--network` | `—` | network name or id to join |

## Your private network

### `fabric down`

Disconnect this machine from the fabric (keeps your login + identity)

```
fabric down
```

### `fabric grant`

Mint a capability token for a private resource (e.g. mcp://local-files)

Mint a short-lived, scoped capability token that lets someone reach one private
resource through the gateway — nothing else, and only until it expires. Give the
token to a teammate or paste it into `fabric resolve`. Revoke reach by letting it
expire (default 10m) rather than reconfiguring the service.

```
fabric grant [resource] [flags]
```

Examples:

```bash
fabric grant mcp://local-files --action read --ttl 30m
```

| flag | default | description |
|---|---|---|
| `--action` | `—` | granted action (default: the kind's action — llm/router/endpoint invoke, mcp read, a2a delegate, tcp connect) |
| `--json` | `false` | JSON output |
| `--ttl` | `10m0s` | token lifetime |

### `fabric ip`

Print this node's overlay IP (or another node's with --name)

```
fabric ip [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |
| `--name` | `—` | print a specific node's overlay IP |

### `fabric join`

Join this machine to a network as a node

Enroll this device: generate a WireGuard keypair, register the public
key, receive an overlay IP, and fetch the signed peer map. The private
key stays on this machine — the control plane never sees it.

```
fabric join [flags]
```

| flag | default | description |
|---|---|---|
| `--name` | `—` | node name (default: hostname) |
| `--network` | `—` | network id to join (default: current network) |

### `fabric names`

List private node/service names from the signed netmap

List the private names on this network — each node and each service, with the
overlay address it resolves to.

THE NAMES DO NOT RESOLVE ON THIS MACHINE BY THEMSELVES

fabric knows them (they come from the signed netmap) and prints them here, but
the operating system's resolver has never heard of them. So this works:

  ssh user@fd16:1bcf:dafd::2

and this does not, until you install the names:

  ssh user@spark-worker.private

--hosts prints the names as an /etc/hosts block, and the commands to install
or remove it. The block is fenced by marker comments so re-installing replaces
it rather than appending a second copy. It is a snapshot: when a node joins or
its address changes, regenerate it.

Nothing is written for you. Installing needs root, and what root changes on
your resolver should be a command you can read first.

```
fabric names [flags]
```

Examples:

```bash
fabric names

# Make the names resolve on this machine.
fabric names --hosts
fabric names --hosts | sudo tee /tmp/fabric-hosts >/dev/null && \
  sudo sh -c 'sed -i.bak "/# >>> agent-fabric names/,/# <<< agent-fabric names/d" /etc/hosts && cat /tmp/fabric-hosts >> /etc/hosts'
```

| flag | default | description |
|---|---|---|
| `--hosts` | `false` | print the names as an /etc/hosts block (stdout), with install/remove commands (stderr) |
| `--json` | `false` | JSON output |

### `fabric ping`

Ping a peer over the overlay and show the path (direct/relay)

```
fabric ping [name] [flags]
```

| flag | default | description |
|---|---|---|
| `--network` | `—` | network the peer is on (name or id; default: current) |

### `fabric resolve`

Resolve a private service through the gateway using a capability

Exchange a capability token (from fabric grant) for the live coordinates of a
private service — the node it runs on and the URL to call it at.

WHICH ADDRESS TO USE

  gateway url   http://127.0.0.1:7777/gw/<network>/<service>
                Call THIS one. It goes through the local gateway, which enforces
                the capability and forwards over the mesh to whichever node runs
                the service. It works whether the service is on this machine or
                another.

  addr          the service's address ON ITS OWN NODE — 127.0.0.1:<port>. It is
                loopback by design, so calling it from any other machine reaches
                your own localhost, not the service.

For an llm service the gateway url is an OpenAI-compatible base URL. The
service's own address already ends in /v1, so the SDK's usual suffixes
(/chat/completions, /models) go straight after the gateway url — do not add
/v1 again, or the path doubles and the call 404s:

  OPENAI_BASE_URL=http://127.0.0.1:7777/gw/<network>/<service>
  OPENAI_API_KEY=<capability token>

--json carries gateway_url too, so an agent reading the output has the same
answer a person does.

```
fabric resolve [service] [flags]
```

Examples:

```bash
fabric resolve local-files --action read --cap <token>

# The coordinates as an agent reads them.
fabric resolve tp2-code --action invoke --cap <token> --json

# A gateway on another port.
fabric resolve tp2-code --cap <token> --gateway http://127.0.0.1:8888
```

| flag | default | description |
|---|---|---|
| `--action` | `—` | requested action (default: the kind's action) |
| `--cap` | `—` | capability token from `fabric grant` |
| `--gateway` | `http://127.0.0.1:7777` | local gateway proxy URL (where `fabric gateway proxy` listens) |
| `--json` | `false` | JSON output |

### `fabric serve`

Publish a local service to your private network

Publish a locally-running service — an LLM/MCP/A2A endpoint or a TCP port —
into your private mesh as an addressable service. The control plane brokers
reachability and capabilities; your traffic stays peer-to-peer (it never sees
prompts or outputs).

Friendly framing of `fabric service add`. Kinds: llm, mcp, a2a, router,
endpoint, tcp.

Example:
  fabric serve http://127.0.0.1:11434/v1 --name mac-ollama --kind llm

```
fabric serve <local-addr> [flags]
```

| flag | default | description |
|---|---|---|
| `--kind` | `llm` | service kind: llm|mcp|a2a|router|endpoint|tcp |
| `--name` | `—` | service name (required), e.g. mac-ollama |
| `--scope` | `—` | capability scope required to reach it |

### `fabric service`

Manage private services on the mesh

```
fabric service
```

### `fabric service add`

Register a private service (mcp://… or a2a://…)

```
fabric service add [uri]
```

### `fabric service inspect`

Show details for a private service (by name or private name)

```
fabric service inspect [name]
```

### `fabric service list`

List private services on the current network

```
fabric service list [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |

### `fabric service remove`

Remove a service published from this node

```
fabric service remove [name]
```

### `fabric service test`

Test reachability of a private service

```
fabric service test [name] [flags]
```

| flag | default | description |
|---|---|---|
| `--timeout` | `3s` | dial timeout |

### `fabric service watch`

Sample a model server's own metrics and say what they mean

Sample a published model server's /metrics and report what it is doing: how
many requests are running, how many are WAITING, how full the KV cache is, how
often the prefix cache hits, and the token rate.

The queue is the number worth the command. A server whose KV cache only fits a
couple of long-context requests will make a third one wait, and from the
client's side that looks exactly like a slow model — so the instinct is to
reach for a bigger machine rather than fewer parallel requests.

Only servers that publish Prometheus metrics can be read this way (vLLM does;
Ollama does not). A server publishing none of these is reported as such, not
rendered as a dashboard of zeros.

```
fabric service watch [service] [flags]
```

Examples:

```bash
fabric service watch glm53-code
fabric service watch glm53-code --for 2m --interval 5s
fabric service watch glm53-code --json
```

| flag | default | description |
|---|---|---|
| `--for` | `30s` | how long to sample |
| `--interval` | `3s` | time between samples |
| `--json` | `false` | JSON output |

### `fabric try`

Prove a published service works — mint access, call it, show the gate

Show the result, not just the setup. `try` mints a short-lived capability for
a service you published, has the control plane's gateway authorize it, proves the
same request is refused without a token, and — for a model — makes one real call so
you see it answer. It's the fastest way to see (and show) what your private AI now does.

```
fabric try <service> [flags]
```

Examples:

```bash
fabric try local-model
fabric try local-files --action read
```

| flag | default | description |
|---|---|---|
| `--action` | `—` | capability action to request (default: the kind's action) |
| `--prompt` | `Reply in one short sentence: are you reachable over the private mesh?` | prompt to send a model service |

### `fabric wait`

Wait until this node is ready (ip, netmap, control)

Exit 0 once the requested readiness signals hold, else fail at --timeout.
Signals: ip (overlay IP assigned), netmap (signed map accepted), control
(control plane reachable). Default: ip,netmap.

```
fabric wait [flags]
```

| flag | default | description |
|---|---|---|
| `--for` | `[ip,netmap]` | signals to wait for: ip,netmap,control |
| `--timeout` | `30s` | maximum time to wait |

### `fabric whois`

Resolve an overlay IP or private name to its node/service (defaults to this node)

```
fabric whois [ip|private-name] [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |

## AI agents

### `fabric agent`

Agent runtime recipes and local supervisor

```
fabric agent
```

### `fabric agent add`

Register an agent runtime recipe

```
fabric agent add [name]
```

### `fabric agent attach`

Attach an existing localhost OpenAI-compatible endpoint

Persist an externally managed model server in Fabric's local runtime state.

Attach is the preferred MVP path for macOS Apple Silicon, Windows, WSL2, native Ollama,
vLLM-Metal, or any OpenAI-compatible server you started yourself. Fabric verifies the
endpoint and records enough metadata for smoke tests, loop sessions, Local Console, and
optional mesh service registration.

```
fabric agent attach [name] [flags]
```

Examples:

```bash
# Attach native Ollama running on the default localhost port.
fabric agent attach mac-ollama \
  --url http://127.0.0.1:11434/v1 \
  --model llama3.2:latest

# Attach an OpenAI-compatible vLLM endpoint.
fabric agent attach existing-vllm \
  --url http://127.0.0.1:18000/v1 \
  --model qwen2.5-0.5b

# Attach and register the LLM service on the current joined mesh node.
fabric agent attach gpu-vllm \
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

### `fabric agent discover`

Discover reachable localhost OpenAI-compatible model endpoints

Probe common localhost model-server ports without starting or modifying anything.

Discovery checks native Ollama and OpenAI-compatible endpoints such as vLLM. When a server
is reachable, Fabric prints the default model and an attach command you can copy. Unreachable
targets are hidden by default; use --all while debugging a local setup.

```
fabric agent discover [flags]
```

Examples:

```bash
# Show reachable model servers and suggested attach commands.
fabric agent discover

# Include failed probe targets to debug ports or server startup.
fabric agent discover --all

# Emit machine-readable discovery results.
fabric agent discover --json
```

| flag | default | description |
|---|---|---|
| `--all` | `false` | include unreachable probe targets |
| `--json` | `false` | print JSON |
| `--timeout` | `5s` | discovery timeout |

### `fabric agent doctor`

Run local runtime preflight checks

Check whether this host can run Fabric-managed local AI runtimes.

Linux hosts are checked for Docker, NVIDIA tooling, and GPU visibility for managed Docker
profiles. macOS Apple Silicon and Windows are attach-first in the MVP, so doctor points you
toward native local servers instead of reporting missing NVIDIA tooling as a hard failure.

```
fabric agent doctor
```

Examples:

```bash
# Check the current host before starting managed profiles.
fabric agent doctor

# macOS/Windows next step after doctor:
fabric agent discover
```

### `fabric agent introspect`

Run an A2A agent that answers this node's mesh status/doctor/connectivity to peers

Expose this node's deterministic mesh diagnostics to peer AGENTS over A2A. A peer
agent sends a message ("status" | "doctor" | "connectivity") and receives the same
JSON digest the CLI renders — no shell access to this node required.

Publish it on the mesh — in another terminal:
  fabric serve <addr> --kind a2a --name mesh-introspect
then a peer reaches it (capability-scoped) through the gateway.

```
fabric agent introspect [flags]
```

| flag | default | description |
|---|---|---|
| `--addr` | `127.0.0.1:7777` | loopback address to bind the A2A introspection agent |

### `fabric agent logs`

Show logs for a Fabric-managed Docker runtime

Read recent Docker logs for a Fabric-managed runtime.

Logs are available for managed Docker profiles. For attached native endpoints, use the
runtime's own logging mechanism, such as the Ollama app, systemd, Docker, or your terminal.

```
fabric agent logs [name] [flags]
```

Examples:

```bash
# Show the last 120 log lines.
fabric agent logs dev-vllm

# Show more lines while debugging model load or readiness.
fabric agent logs dev-vllm --tail 500
```

| flag | default | description |
|---|---|---|
| `--tail` | `120` | number of log lines |

### `fabric agent loop`

Run or resume a local long-running agent loop

Run a session-backed local loop against an attached or managed runtime.

The loop is coordinated by aflocal, so start aflocal before running this command. Fabric
records each step as a local event and checkpoint, polls for cancellation, retries transient
step failures with backoff, and can compact/redact older local context. Prompts and outputs
stay in the local session store under ~/.fabric; they are not sent to the Fabric cloud.

```
fabric agent loop [runtime] [flags]
```

Examples:

```bash
# Terminal 1: start the Local Console backend.
aflocal

# Terminal 2: run three local loop steps.
fabric agent loop mac-ollama \
  --steps 3 \
  --prompt "Continue the local maintenance task and report concise progress." \
  --redact

# Resume the same session from its last loop-step checkpoint.
fabric agent loop mac-ollama --session sess_abc123 --steps 3

# Use a non-default aflocal URL, useful in tests or multiple local instances.
fabric agent loop mac-ollama --local-url http://127.0.0.1:13210 --steps 1 --json
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

### `fabric agent reach`

Measure the round-trip to an agent service over the mesh (MCP/A2A)

Time a real agent-protocol call to a private service — MCP tools/list or the A2A
agent card — through the authorizing gateway. Reports whether it answered, the
round-trip latency, what it exposes, and the live tunnel path (direct/relay).
Needs a capability (`fabric grant`) and a running local gateway (`fabric gateway proxy`).

```
fabric agent reach [service] [flags]
```

Examples:

```bash
fabric agent reach mesh-introspect --cap <token>
```

| flag | default | description |
|---|---|---|
| `--action` | `tools/list` | action to authorize (JSON-RPC method for MCP) |
| `--cap` | `—` | capability token from `fabric grant` |
| `--gateway` | `http://127.0.0.1:7777` | local gateway proxy URL |
| `--json` | `false` | JSON output |

### `fabric agent run`

Run a composed agent on a task (uses its model, instructions and tools)

Run one reason→act pass for an agent you composed in the Local Console: it uses the
agent's model runtime and instructions, and can call the MCP tools wired to it — the
tool calls are executed for it and fed back. Needs aflocal running. The agent is named
or referenced by id.

```
fabric agent run [agent] [flags]
```

Examples:

```bash
fabric agent run researcher --prompt "summarize today's local notes"
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |
| `--local-url` | `—` | Local Console URL (default: http://127.0.0.1:3210) |
| `--max-rounds` | `0` | max tool rounds (default: server default) |
| `--prompt` | `—` | the task for the agent |

### `fabric agent session`

Inspect and control local agent sessions

Inspect and control sessions stored by the Local Agent Stack.

Sessions contain local-only events and checkpoints from smoke tests, loop runs, and future
agent/tool workflows. Use these commands to observe progress, follow live updates, cancel a
running loop, compact old context, or collect JSON for a local UI or script.

```
fabric agent session
```

Examples:

```bash
fabric agent session list
fabric agent session show sess_abc123
fabric agent session follow sess_abc123
fabric agent session cancel sess_abc123
fabric agent session compact sess_abc123 --redact-events --redact-checkpoints
```

### `fabric agent session cancel`

Cancel a local agent session

Mark a local session as cancelled.

Running loops poll the session status before each step and during retry backoff, so cancel is
observed without killing aflocal. A cancelled session is intentionally not reused; create a
new session or resume one that is not cancelled.

```
fabric agent session cancel [session-id] [flags]
```

Examples:

```bash
# Cancel an in-progress local loop.
fabric agent session cancel sess_abc123

# JSON output for automation.
fabric agent session cancel sess_abc123 --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | print JSON |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |

### `fabric agent session compact`

Compact local session context

Create a local compaction checkpoint and optionally redact older local payloads.

Compaction keeps recent events visible and records a summary checkpoint. With redaction
flags, older event contents and checkpoint states are replaced locally. This helps long-running
agent sessions stay inspectable without leaving all prompts and outputs in the visible tail.

```
fabric agent session compact [session-id] [flags]
```

Examples:

```bash
# Add a summary checkpoint but keep payloads visible.
fabric agent session compact sess_abc123 \
  --summary "Completed environment setup; next step is validation"

# Keep the latest 20 events and redact older event/checkpoint payloads.
fabric agent session compact sess_abc123 \
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

### `fabric agent session follow`

Follow live local session updates

Open the local session SSE stream and print live updates.

Follow first replays stored session, event, and checkpoint frames, then keeps the connection
open for new updates. It is useful while another terminal runs fabric agent loop. Stop it
with Ctrl-C.

```
fabric agent session follow [session-id] [flags]
```

Examples:

```bash
# Terminal 1: watch a session.
fabric agent session follow sess_abc123

# Terminal 2: resume work and watch updates appear in terminal 1.
fabric agent loop mac-ollama --session sess_abc123 --steps 5
```

| flag | default | description |
|---|---|---|
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |

### `fabric agent session list`

List local agent sessions

List sessions stored by aflocal under ~/.fabric/sessions.

The table shows status, runtime, model, event count, checkpoint count, update time, and
title. Use the session id with show, follow, cancel, compact, or agent loop --session.

```
fabric agent session list [flags]
```

Examples:

```bash
# Human-readable table.
fabric agent session list

# JSON for scripts or a local UI.
fabric agent session list --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | print JSON |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |

### `fabric agent session show`

Show a local agent session

Show session metadata plus recent events and checkpoints.

Use --tail to control how many recent events and checkpoints are printed. Use --json when
you need full event metadata, checkpoint state, or exact timestamps for debugging.

```
fabric agent session show [session-id] [flags]
```

Examples:

```bash
# Show the default recent event/checkpoint tail.
fabric agent session show sess_abc123

# Show more local history.
fabric agent session show sess_abc123 --tail 50

# Dump full structured detail.
fabric agent session show sess_abc123 --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | print JSON |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |
| `--tail` | `10` | events/checkpoints to show |

### `fabric agent smoke`

Run workload smoke and optional model-server capability checks

Verify that an attached or managed runtime is usable for local agent workflows.

Required checks cover streaming, multi-turn recall, local memory injection, and durable
loop checkpoint behavior. Optional capability checks record support for /v1/models, JSON
mode, tool/function calling, embeddings, and /v1/responses without failing the command when
a model server simply does not implement an optional feature.

```
fabric agent smoke [name] [flags]
```

Examples:

```bash
# Run the default smoke suite against an attached Ollama runtime.
fabric agent smoke mac-ollama

# Run more durable loop iterations.
fabric agent smoke dev-vllm --loops 5 --timeout 5m

# Check the model's Korean survives this checkpoint — some conversions
# corrupt multi-byte characters and report nothing.
fabric agent smoke dev-vllm --locale ko

# A good operator flow after smoke passes:
fabric agent loop dev-vllm --steps 3
```

| flag | default | description |
|---|---|---|
| `--locale` | `[]` | also check text survives a round trip in these languages (ko, ja, zh) — a quantized checkpoint can corrupt multi-byte characters with no error |
| `--loops` | `3` | durable loop iterations |
| `--timeout` | `3m0s` | smoke timeout |

### `fabric agent start`

Start a known local AI runtime profile

Start a known, audited runtime profile. Managed start is Linux/NVIDIA Docker-first:
vllm-docker and ollama-docker. On macOS Apple Silicon or Windows, run a native
local server (Ollama, MLX/vLLM-Metal, WSL2) and attach it instead — Fabric does
not vendor model servers or weights.

Use start when Fabric should own the container lifecycle. Use attach when a model
server is already running, or when the platform is not Linux/NVIDIA Docker.

CHOOSING THE MACHINE

  --node NAME   run it on another machine on the mesh instead of this one. Same
                profile, same flags, same -- passthrough; that node executes it
                and reports back.
  --follow      with --node, wait for the machine to report the result instead of
                returning as soon as the request is queued.

A remote start is a desired-state job, not a remote shell. The node picks the
image, every docker-level flag and the loopback port binding from its own
compiled-in profile; the request chooses WHICH profile and what to pass the model
server. There is no field that could ask for a different image, a bind mount, a
privileged container, or a port on a public interface.

A job for a machine that is offline is not lost — it runs when that node next
polls. And --follow running out of time is NOT a failure: a cold host pulls a
multi-gigabyte image before the container starts, so "still pending" means still
working.

RUNTIME ARGUMENTS (after --)

Everything after a bare -- is handed to the model server untouched, the way
docker and kubectl pass a command through:

  fabric agent start --runtime vllm-docker -- --tensor-parallel-size 2

The runtime's own surface is far larger than the flags mirrored here — tensor and
pipeline parallelism, KV transfer for prefill/decode separation, quantization —
and mirroring it one flag at a time would always lag the runtime. Anything the
server accepts works, locally or with --node.

These replace the built-in first-run defaults where they collide. Fabric opens a
vLLM container with a deliberately small window (--max-model-len 1024, 20% of the
GPU) so a first run succeeds on a modest card; passing your own value for one of
those means yours, not a value you never asked for.

Arguments are passed as argv, never through a shell, so quoting and metacharacters
are inert. They cannot reach docker's own flags: they are appended after the
image, so there is no position from which a bind mount or a privileged flag could
be introduced.

```
fabric agent start [flags]
```

Examples:

```bash
# Start a vLLM Docker profile on a Linux/NVIDIA host.
fabric agent start --runtime vllm-docker --name dev-vllm

# Start vLLM with an explicit Hugging Face model and served OpenAI model name.
fabric agent start \
  --runtime vllm-docker \
  --name qwen-dev \
  --model Qwen/Qwen2.5-0.5B-Instruct \
  --served-model qwen2.5-0.5b \
  --port 18000

# Start Ollama in Docker and register the resulting LLM service on the mesh.
fabric agent start --runtime ollama-docker --name dev-ollama --register

# Pass runtime arguments through after --. Anything the runtime accepts works;
# these are vLLM's, and they replace the built-in first-run defaults.
fabric agent start --runtime vllm-docker -- --tensor-parallel-size 2 --max-model-len 32768

# Start it on ANOTHER machine on the mesh instead of this one. Same profile,
# same flags, same passthrough — the node runs it and reports back.
fabric agent start --node spark-2 --runtime vllm-docker --register --follow \
  -- --tensor-parallel-size 2
```

| flag | default | description |
|---|---|---|
| `--follow` | `false` | with --node: wait for the machine to report the result |
| `--model` | `—` | model to load or pull (default depends on runtime) |
| `--name` | `—` | local runtime name |
| `--node` | `—` | start it on this mesh machine (name or node id) instead of here |
| `--port` | `0` | localhost port (default depends on runtime) |
| `--pull` | `true` | pull the model when the runtime supports it |
| `--register` | `false` | register the resulting llm service on the current mesh node |
| `--runtime` | `vllm-docker` | runtime profile: vllm-docker|ollama-docker (Linux/NVIDIA Docker) |
| `--served-model` | `—` | OpenAI-compatible served model name (vLLM) |
| `--wait` | `4m0s` | readiness timeout |

### `fabric agent status`

Show local Fabric-managed or attached runtimes

List runtime records stored under ~/.fabric/runtimes.

The table includes both Fabric-managed Docker profiles and externally managed endpoints
attached with fabric agent attach. This is the fastest way to confirm the runtime name to
use with smoke, loop, logs, stop, or Local Console API calls.

```
fabric agent status [flags]
```

Examples:

```bash
fabric agent status

# Typical next steps:
fabric agent smoke mac-ollama --loops 3
fabric agent loop mac-ollama --steps 3
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | print JSON |

### `fabric agent stop`

Stop a Fabric-managed runtime or detach an external endpoint

Stop a Fabric-managed Docker runtime, or remove an attached external endpoint from local state.

For attached native runtimes, Fabric does not stop the real server process; it only detaches
the runtime record. Stop Ollama, vLLM, or other native servers with their own tools.

```
fabric agent stop [name]
```

Examples:

```bash
# Stop a Fabric-managed Docker profile.
fabric agent stop dev-vllm

# Detach a native/external endpoint from Fabric local state.
fabric agent stop mac-ollama
```

### `fabric console`

Open a remote node's Local Console; manage console access (ACL)

```
fabric console
```

### `fabric console grant`

Grant a subject access to a node's Local Console (zero-trust ACL)

Author an ACL grant: <subject> (the grantee's identity) may open <node>'s
console. Use the node name or id, or "*" for every node in the network.
Without a grant, remote console access is denied (default-deny).

```
fabric console grant [subject] [node] [flags]
```

| flag | default | description |
|---|---|---|
| `--ttl` | `0s` | grant expiry (e.g. 24h; 0 = no expiry) |

### `fabric console grants`

List console access grants (the ACL) for the current network

```
fabric console grants
```

### `fabric console open`

Open a remote node's Local Console over the private network

```
fabric console open [node] [flags]
```

| flag | default | description |
|---|---|---|
| `--no-open` | `false` | print the URL without opening a browser |

### `fabric console revoke`

Revoke a subject's console access to a node

```
fabric console revoke [subject] [node]
```

### `fabric models`

Find and size local-runnable models (Hugging Face catalog)

```
fabric models
```

### `fabric models pull`

Pull the right quant for your GPU via Ollama, then publish it privately

One command from a Hugging Face model id to a running, private service:
we pick the quantization that fits your GPU (override with --quant), pull it via
Ollama's Hugging Face passthrough, then attach + publish it on your mesh. Needs a
running Ollama (`ollama serve`) and aflocal for the publish step.

```
fabric models pull [model-id] [flags]
```

Examples:

```bash
fabric models pull Qwen/Qwen2.5-7B-Instruct-GGUF
fabric models pull unsloth/gemma-2-9b-it-GGUF --quant Q4_K_M
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

### `fabric models search`

Search trending models that run locally, sized to your GPU

```
fabric models search [query] [flags]
```

Examples:

```bash
fabric models search qwen2.5
fabric models search llama --sort recent --json
```

| flag | default | description |
|---|---|---|
| `--all` | `false` | include models without local (GGUF) weights |
| `--json` | `false` | JSON output |
| `--limit` | `15` | max results |
| `--sort` | `trending` | trending | likes | recent |
| `--vram` | `0` | GPU VRAM in GB to size against (default: auto-detect via aflocal) |

### `fabric models show`

Show a model's quantizations and which one we'd run on your GPU

Size a model against this machine: what each quantization needs, what happens if
you run it, and which one we would pick.

ARGUMENT

  [model-id]   a Hugging Face repo, e.g. bartowski/Qwen2.5-7B-Instruct-GGUF.
               The parameter count is read from the NAME ("...-7B"). A repo whose
               name carries no size cannot be sized at all, and says so rather
               than showing 0.0 GB — which would make every quant look like it fits.

WHAT THE VERDICTS MEAN

  fits                 needs at most 80% of your VRAM. The headroom is for a KV
                       cache that grows with the conversation.
  tight                fits, with no room to grow.
  runs, partly in RAM  over the VRAM line, but the runtime can keep some layers
                       in system memory. Slower, not impossible — this is NOT a
                       refusal, and treating it as one talks you out of something
                       that works.
  won't fit            too big for the GPU AND the memory behind it.

The estimate is weights + KV cache at the chosen context + a fixed runtime
overhead. It is approximate: the exact KV figure needs a model's layer and head
counts, which a repo name does not carry.

FLAGS THAT CHANGE THE ANSWER

  --vram N     size against N GB instead of auto-detecting. Auto-detection asks
               the local agent (aflocal); pass this when it is not running, or to
               ask "what would this need on a different machine?".

               On unified-memory hardware (Apple Silicon, NVIDIA Grace/GB10) the
               pool is shared with the CPU. Fabric reports it as unified and does
               not treat it as spare capacity to offload into, because there is
               no second tier to offload to.

  --context N  size the KV cache against an N-token window (default 8192). This
               is the term that scales with the CONVERSATION rather than the
               model, so it changes the answer a lot: a 7B that fits comfortably
               at 8K can be too big for the same card at 128K. Size against the
               context you actually intend to serve.

```
fabric models show [model-id] [flags]
```

Examples:

```bash
# What would we run on this machine?
fabric models show bartowski/Qwen2.5-7B-Instruct-GGUF

# Size it for a 128K context — the KV cache, not the weights, is what grows.
fabric models show bartowski/Qwen2.5-7B-Instruct-GGUF --context 131072

# Ask about a machine you are not sitting at.
fabric models show meta-llama/Llama-3.3-70B-Instruct --vram 80
```

| flag | default | description |
|---|---|---|
| `--context` | `8192` | context window (tokens) to size the KV cache against |
| `--json` | `false` | JSON output |
| `--vram` | `0` | GPU VRAM in GB (default: auto-detect via aflocal) |

### `fabric web`

Open the Local Console for this machine

Open the localhost Local Console served by aflocal.

Start aflocal first if it is not already running. The Local Console is
loopback-only and manages this node's AI runtimes, sessions, hardware,
diagnostics, and private names.

```
fabric web [flags]
```

| flag | default | description |
|---|---|---|
| `--addr` | `127.0.0.1:3210` | Local Console listen address |
| `--local-url` | `http://127.0.0.1:3210` | Local Console URL |
| `--no-open` | `false` | check and print the URL without opening a browser |

## Account

### `fabric login`

Authenticate to Agent-Fabric (org/human identity)

Authenticate to Agent-Fabric.

With no flags, runs the browser device flow (RFC 8628): the CLI shows a
code you approve at the control plane's app — works on servers/containers
with no local browser.

--token <jwt>       store a real Cognito ID token (AWS mode), no device flow.

```
fabric login [flags]
```

| flag | default | description |
|---|---|---|
| `--token` | `—` | raw Cognito ID token (AWS mode) |

### `fabric logout`

Clear the local Agent-Fabric session

Clear the local session (token + refresh). By default the device identity —
the WireGuard private key and machine-key seed — is KEPT so you can sign back
in without re-enrolling. Use --purge to also erase the device identity from
this machine (e.g. before handing it off); revoking the device in the console
is still the way to invalidate it server-side.

```
fabric logout [flags]
```

| flag | default | description |
|---|---|---|
| `--purge` | `false` | also erase the local device identity (WireGuard key + machine seed) |

### `fabric network`

Manage private overlay networks

```
fabric network
```

### `fabric network create`

Create a new private network

```
fabric network create [name]
```

### `fabric network delete`

Delete an empty network (by name or id)

Delete a network you own. The network must be empty — remove its nodes
first. This cannot be undone.

```
fabric network delete [network] [flags]
```

| flag | default | description |
|---|---|---|
| `--yes` | `false` | skip the confirmation prompt |

### `fabric network list`

List your networks

```
fabric network list [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |

### `fabric network prune`

Delete empty networks (no machines) — explicit cleanup, with confirmation

Find networks that have no machines and delete them, so stale networks
left over from testing don't pile up. Networks that still have machines are
never touched, and nothing is deleted without your confirmation (or --yes).
This never runs automatically — it's the manual counterpart to the 'idle'
state shown by `fabric network list`.

```
fabric network prune [flags]
```

| flag | default | description |
|---|---|---|
| `--yes` | `false` | skip the confirmation prompt |

### `fabric network rename`

Rename a network (by name or id)

```
fabric network rename [network] [new-name]
```

### `fabric node`

Manage nodes on the current network

```
fabric node
```

### `fabric node check`

Ask nodes for a health report and show what differs between them

Ask each online node (or one node) to run a health check and answer with a
report: its afd version, OS, accelerators with driver versions, and its runtime
stack's own doctor lines (docker, nvidia-smi, the nvidia container runtime).
The reports are shown side by side, then what matters is called out:

  - afd versions that differ between machines
  - NVIDIA driver versions that differ — tensor-parallel across them will fail
  - a machine's own warnings (docker missing, nvidia runtime not listed, …)
  - machines that are offline, or did not answer in time

A node on an older afd answers with a one-line "responsive" and no report; it
is shown as such, not as a failure. Nothing is changed on any node: a check is
read-only, and the node does the reading on its own poll.

```
fabric node check [name] [flags]
```

Examples:

```bash
fabric node check              # every online node on the current network
fabric node check spark-2      # one node
fabric node check --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |
| `--wait` | `1m30s` | how long to wait for nodes to answer |

### `fabric node list`

List nodes on a network (default: current; --network for any you own)

```
fabric node list [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |
| `--network` | `—` | network name or id (default: the joined one) |

### `fabric node remove`

Remove a node from a network (revokes its access)

Revoke a node's membership. It loses access immediately; reconnect it later
with `fabric up`. Removing this machine's own node disconnects it. Use
--network to remove a node from a network you own without being joined to it
(e.g. clearing a stale registration after a local reset).

```
fabric node remove [name] [flags]
```

| flag | default | description |
|---|---|---|
| `--network` | `—` | network name or id (default: the joined one) |
| `--yes` | `false` | skip the confirmation prompt |

### `fabric node rename`

Rename a node (keeps its overlay IP)

```
fabric node rename [current-name] [new-name] [flags]
```

| flag | default | description |
|---|---|---|
| `--network` | `—` | network the node is on (name or id; default: current) |

### `fabric node revoke`

Permanently revoke a node's device identity (lost/stolen device)

Revoke removes the node AND blacklists its device (machine) identity, so a
lost or stolen device — whose holder still has the machine key — can NEVER
re-enroll in this org. Use `node remove` for a normal removal the device can
undo by reconnecting; revoke is permanent for that device key.

```
fabric node revoke [name] [flags]
```

| flag | default | description |
|---|---|---|
| `--network` | `—` | network the node is on (name or id; default: current) |
| `--yes` | `false` | skip confirmation |

### `fabric node show`

Show details for a node

Show a node's identity, address, status and published services.

Use --network to look at a node on a network you own without being joined
to it — the same situation `node remove --network` handles, and the natural
thing to do BEFORE removing: check what is there. It used to be possible to
delete a stale registration from outside the network but not to inspect it.

```
fabric node show [name] [flags]
```

Examples:

```bash
fabric node show spark-worker

# A node on a network this machine is not joined to.
fabric node show spark-head --network nw_b34217b281234362
```

| flag | default | description |
|---|---|---|
| `--network` | `—` | network name or id (default: the joined one) |

### `fabric nodes`

List nodes on the current network

```
fabric nodes
```

### `fabric usage`

Show this workspace's metered usage (relay egress, api, node-hours)

```
fabric usage [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | emit usage as JSON |

### `fabric whoami`

Show the current identity: workspace, plan, control plane, node

```
fabric whoami [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON output |

### `fabric workspace`

Manage your workspace: name, members, invitations

```
fabric workspace
```

### `fabric workspace invite`

Invite a teammate by email

Invite a teammate to the workspace. They appear as a pending member until
an accept flow lands. Role is member (default) or admin.

```
fabric workspace invite [email] [flags]
```

| flag | default | description |
|---|---|---|
| `--role` | `member` | member or admin |

### `fabric workspace members`

List workspace members and pending invitations

```
fabric workspace members
```

### `fabric workspace rename`

Rename the workspace

```
fabric workspace rename [name]
```

### `fabric workspace revoke`

Revoke a pending invitation

```
fabric workspace revoke [invitation-id] [flags]
```

| flag | default | description |
|---|---|---|
| `--yes` | `false` | skip the confirmation prompt |

### `fabric workspace show`

Show the current workspace (name, plan, owner)

```
fabric workspace show
```

## Diagnostics

### `fabric bugreport`

Generate a privacy-safe support bundle (no prompts, outputs, tokens, or keys)

Collect just enough metadata to debug join/runtime/connectivity issues —
version, OS/arch, control host, org/network/node ids, the signed netmap
generation/entitlement/peer+service counts, and the observe-engine diagnostics
(doctor/status/connectivity verdicts). It NEVER includes tokens, keys, prompts,
model outputs, or session content.

```
fabric bugreport [flags]
```

| flag | default | description |
|---|---|---|
| `--output` | `—` | write the bundle to a file instead of stdout |

### `fabric control-key`

Inspect or rotate the pinned control-plane verify key (trust anchor)

```
fabric control-key
```

### `fabric control-key repin`

Pin the key the control plane currently serves (after a legitimate rotation)

```
fabric control-key repin [flags]
```

| flag | default | description |
|---|---|---|
| `--yes` | `false` | skip the confirmation prompt (for automation) |

### `fabric control-key show`

Show the pinned control key and whether it matches the server

```
fabric control-key show
```

### `fabric doctor`

Diagnose local setup: config, identity, keystore, control plane, node (--json for agents)

```
fabric doctor [flags]
```

Examples:

```bash
fabric doctor
fabric doctor --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | emit the report as a structured JSON digest (for agents/automation) |

### `fabric host`

Deterministic host snapshot: os, cpu/load, memory, disk, network (--json for agents)

A deterministic host snapshot — OS/kernel, CPU + load average, memory, the root
filesystem, and up network interfaces — gathered from machine-readable sources.
An agent reads it in one call instead of running uname/df/ip/free across turns.

```
fabric host [flags]
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | emit the snapshot as a structured JSON digest (for agents/automation) |

### `fabric netcheck`

Diagnose mesh connectivity: control, netmap, relay, NAT, and per-peer path (--json for agents)

```
fabric netcheck [flags]
```

Examples:

```bash
fabric netcheck
fabric netcheck --json
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | emit the diagnosis as a structured JSON digest (for agents/automation) |

## Advanced

### `fabric agent-workspace`

Agent workspaces (agent + model + tool services)

```
fabric agent-workspace
```

### `fabric agent-workspace create`

Create an agent workspace

```
fabric agent-workspace create [flags]
```

| flag | default | description |
|---|---|---|
| `--name` | `—` | workspace name |
| `--network` | `—` | network id |
| `--purpose` | `—` | purpose, e.g. research |

### `fabric agent-workspace list`

List agent workspaces

```
fabric agent-workspace list
```

### `fabric agent-workspace smoke-test`

Run the structural smoke test

```
fabric agent-workspace smoke-test <workspace-id>
```

### `fabric customer-env`

Customer environments (VPC/on-prem)

```
fabric customer-env
```

### `fabric customer-env create`

Represent a customer environment

```
fabric customer-env create [flags]
```

| flag | default | description |
|---|---|---|
| `--customer` | `—` | customer name |
| `--name` | `—` | environment name |
| `--region` | `—` | region |
| `--type` | `aws_vpc` | environment type |

### `fabric customer-env list`

List customer environments

```
fabric customer-env list
```

### `fabric customer-env preflight`

Run the trust-boundary + readiness check

```
fabric customer-env preflight <env-id>
```

### `fabric delivery`

Delivery projects (AI-SI customer deliveries)

```
fabric delivery
```

### `fabric delivery handoff`

Export the handoff document (markdown)

```
fabric delivery handoff <project-id>
```

### `fabric delivery init`

Initialize a delivery project

```
fabric delivery init [flags]
```

| flag | default | description |
|---|---|---|
| `--customer` | `—` | customer name |
| `--name` | `—` | project name |
| `--stage` | `pilot` | stage: pilot|poc|production|closed |

### `fabric delivery list`

List delivery projects

```
fabric delivery list
```

### `fabric endpoint`

OpenAI-compatible endpoint recipes

```
fabric endpoint
```

### `fabric endpoint add`

OpenAI-compatible endpoint recipes

Apply a endpoint recipe: print the local setup plan and register the resulting
private service on this machine's mesh entry.

The steps are PRINTED, not run. Fabric shows you the commands (a docker run, a
health check) and you run them on the host; it does not execute a recipe's shell
on your behalf. What it does for real is publish the service, so peers can reach
it through the capability-gated forwarder.

ARGUMENT

  [name]    which recipe to apply. Built in: openai-chat-compatible, openai-responses
            Plus any manifest in ~/.fabric/recipes.

WRITING YOUR OWN

Drop a YAML file in ~/.fabric/recipes. A manifest whose category and name match a built-in
REPLACES it, which is how you change an image or the arguments a runtime starts
with without waiting for a release:

  # ~/.fabric/recipes/my-runtime.yaml
  name: my-runtime           # what you pass to: fabric endpoint add my-runtime
  category: endpoint
  summary: One line shown when the recipe is applied.
  requires: [docker]         # printed as a prerequisite, not checked
  steps:
    - name: start
      run: "docker run -d --name my-runtime -p 127.0.0.1:18100:8000 my/image"
      check: "curl -sf http://127.0.0.1:18100/health"
  service_kind: endpoint
  service:
    name: my-runtime
    kind: endpoint
    addr: "127.0.0.1:18100"  # MUST be loopback — see below
    scope: "endpoint:invoke"

The published address must be loopback (127.0.0.1 or localhost). A recipe may
only publish services on the machine applying it; peers reach them through the
mesh forwarder, which re-checks the capability. A manifest pointing anywhere
else is rejected with the reason, and a manifest fabric cannot read is named
rather than skipped in silence.

```
fabric endpoint add [name]
```

Examples:

```bash
# Apply a built-in recipe.
fabric endpoint add openai-chat-compatible

# Apply one you wrote yourself (~/.fabric/recipes/my-runtime.yaml).
fabric endpoint add my-runtime
```

### `fabric gateway`

Run the local agent-protocol gateway

```
fabric gateway
```

### `fabric gateway proxy`

Run the local gateway: forward authorized MCP/A2A calls over the mesh

Run the local gateway. An MCP/A2A client or an OpenAI SDK points at it; each call
is authorized against the control plane (capability + service resolution) and
reverse-proxied over the mesh to whichever node runs the service. The control
plane sees the resolve, never the payload.

URL SHAPE

  http://127.0.0.1:7777/gw/<network>/<service>[/subpath]

<network> is the network id, or its name. <service> is the private service
name. For an llm service this is an OpenAI-compatible base URL: the service's
own address already ends in /v1, so /chat/completions goes straight after it.
`fabric resolve <service> --cap <cap>` prints the exact url.

AUTHORIZATION CACHE (--auth-cache, on by default)

Without it every request waits for a control-plane round trip before being
forwarded — measured at ~750 ms per call from Korea to a US control plane, for
a service on the same machine. With it, the first call for a capability still
resolves synchronously; later calls are answered from memory and the resolve is
made in the background instead. Every request still produces exactly one
resolve, so usage is counted exactly, and a refusal (revoked, expired) evicts
the entry so the NEXT call is refused. Demo-room tokens never use the cache:
their per-call caps must gate the call before it happens.

SELF-SERVE (--self-serve, off by default)

For your OWN machine. A request that carries no capability — or an API key that
is not one, which is what an OpenAI SDK sends with a placeholder key — gets a
capability minted on your session and renewed before it expires, for as long as
the gateway runs. One base URL, one placeholder key, no ten-minute re-grant:

  OPENAI_BASE_URL=http://127.0.0.1:7777/gw/<network>/<service>
  OPENAI_API_KEY=local

It only binds to loopback: anything that can reach the port can reach every
service your session can, so it must not be a port other machines can reach.
A request that carries a real capability is authorized by that capability.

```
fabric gateway proxy [flags]
```

| flag | default | description |
|---|---|---|
| `--auth-cache` | `true` | answer repeat calls from memory and resolve in the background (see --help) |
| `--listen` | `127.0.0.1:7777` | local listen address (loopback by default) |
| `--self-serve` | `false` | mint and renew capabilities on your session for requests that carry none — loopback only (see --help) |

### `fabric gpu-workspace`

Private GPU workspaces (team model endpoints)

```
fabric gpu-workspace
```

### `fabric gpu-workspace create`

Register a GPU node as a team model endpoint

```
fabric gpu-workspace create [flags]
```

| flag | default | description |
|---|---|---|
| `--name` | `—` | workspace name |
| `--node` | `—` | GPU node id |

### `fabric gpu-workspace detect`

Detect the node's GPU/runtime capabilities

```
fabric gpu-workspace detect <workspace-id>
```

### `fabric gpu-workspace list`

List GPU workspaces

```
fabric gpu-workspace list
```

### `fabric gpu-workspace publish`

Remotely publish a loopback model service on the GPU node (APPLY_RECIPE)

```
fabric gpu-workspace publish <workspace-id> [flags]
```

| flag | default | description |
|---|---|---|
| `--addr` | `—` | local address, e.g. 127.0.0.1:11434 (loopback only) |
| `--kind` | `llm` | model kind: llm|router|endpoint |
| `--name` | `—` | service name (dns-safe) |

### `fabric llm`

Local LLM runtime recipes

```
fabric llm
```

### `fabric llm init`

Local LLM runtime recipes

Apply a llm recipe: print the local setup plan and register the resulting
private service on this machine's mesh entry.

The steps are PRINTED, not run. Fabric shows you the commands (a docker run, a
health check) and you run them on the host; it does not execute a recipe's shell
on your behalf. What it does for real is publish the service, so peers can reach
it through the capability-gated forwarder.

ARGUMENT

  [name]    which recipe to apply. Built in: ollama, ollama-docker, vllm, vllm-docker
            Plus any manifest in ~/.fabric/recipes.

WRITING YOUR OWN

Drop a YAML file in ~/.fabric/recipes. A manifest whose category and name match a built-in
REPLACES it, which is how you change an image or the arguments a runtime starts
with without waiting for a release:

  # ~/.fabric/recipes/my-runtime.yaml
  name: my-runtime           # what you pass to: fabric llm init my-runtime
  category: llm
  summary: One line shown when the recipe is applied.
  requires: [docker]         # printed as a prerequisite, not checked
  steps:
    - name: start
      run: "docker run -d --name my-runtime -p 127.0.0.1:18100:8000 my/image"
      check: "curl -sf http://127.0.0.1:18100/health"
  service_kind: llm
  service:
    name: my-runtime
    kind: llm
    addr: "127.0.0.1:18100"  # MUST be loopback — see below
    scope: "llm:invoke"

The published address must be loopback (127.0.0.1 or localhost). A recipe may
only publish services on the machine applying it; peers reach them through the
mesh forwarder, which re-checks the capability. A manifest pointing anywhere
else is rejected with the reason, and a manifest fabric cannot read is named
rather than skipped in silence.

```
fabric llm init [name]
```

Examples:

```bash
# Apply a built-in recipe.
fabric llm init ollama

# Apply one you wrote yourself (~/.fabric/recipes/my-runtime.yaml).
fabric llm init my-runtime
```

### `fabric lock`

Write down every version this deployment is running (`fabric lock > DEPLOYMENT_LOCK.md`)

Record what this network is actually running, so a deployment that works can be
told apart from one that used to.

It collects, for every node: the afd and client versions, OS and architecture,
CPU and memory, each accelerator with its driver version and backend, the
runtime stack's own report (Docker, nvidia-smi, the container runtime), the
watched kernel tunables, and every interface's MTU. Then the network id and
generation, every published service with the node it lives on, and every
runtime fabric itself started, with the model and revision it was given.

Markdown on stdout, so the usual thing works:

  fabric lock > DEPLOYMENT_LOCK.md

Nothing is changed on any node: each one is asked for a health report, which is
the same read-only check `fabric node check` runs.

```
fabric lock [flags]
```

Examples:

```bash
fabric lock > DEPLOYMENT_LOCK.md
fabric lock --json | jq .nodes[].gpus
```

| flag | default | description |
|---|---|---|
| `--json` | `false` | JSON instead of Markdown |
| `--wait` | `1m30s` | how long to wait for nodes to report |

### `fabric mcp`

Run a local MCP server exposing the mesh digests (status, connectivity, doctor, host) as tools

Expose fabric's deterministic mesh diagnostics to an LLM agent over MCP (stdio).

Tools:
  mesh_status        host+mesh health snapshot (node, control, entitlement, tunnel, relay, peers)
  mesh_connectivity  path diagnosis (control → netmap → relay → NAT → per-peer) with fix hints
  mesh_doctor        local setup + security posture (config, keystore, control key drift, MTU/CIDR)
  host_snapshot      deterministic host snapshot (OS, CPU/load, memory, disk, interfaces)

Add to an MCP client (e.g. Claude Code): {"command":"fabric","args":["mcp"]}

```
fabric mcp
```

### `fabric plan`

Measure and recommend before you commit hardware

```
fabric plan
```

### `fabric plan distributed`

Measure the link to your GPU peers and recommend how (or whether) to split a model

Measure the overlay link from this machine to each GPU node — path (direct or
relay), round-trip time, and throughput — then say how a model can be served
on these machines, in order of preference:

  1. on one node, unquantized, if it fits
  2. on one node at a smaller quantization, if that fits
  3. tensor-parallel across nodes — only over a link of at least 25 Gbps,
     which no overlay provides; a direct QSFP / 25GbE link between the
     machines does, and TP should run over THAT, outside fabric
  4. pipeline-parallel across nodes — workable over a LAN-grade overlay
     (≥ 500 Mbps, ≤ 5 ms), at the cost of latency

The throughput probe pulls zeros from the peer's afd over the overlay. A peer
on an older afd cannot serve it; pass --link-mbps from an iperf3 run instead.
Nothing is started or changed on any node.

```
fabric plan distributed [flags]
```

Examples:

```bash
fabric plan distributed                             # every GPU peer, link only
fabric plan distributed --model Qwen/Qwen2.5-72B-Instruct
fabric plan distributed --peer spark-2 --model meta-llama/Llama-3.1-70B --context 32768
fabric plan distributed --link-mbps 850 --model Qwen/Qwen2.5-72B-Instruct   # link measured elsewhere
```

| flag | default | description |
|---|---|---|
| `--context` | `8192` | context window to size the KV cache for |
| `--json` | `false` | JSON output |
| `--link-mbps` | `0` | use this link throughput instead of probing (from iperf3, or a peer on an older afd) |
| `--model` | `—` | model id to plan for (e.g. Qwen/Qwen2.5-72B-Instruct); size is read from the id |
| `--peer` | `—` | plan for this one peer only (default: every GPU node) |

### `fabric plan launch`

Work out the memory a model server can actually have on these nodes

Do the arithmetic a model server does at startup, before the download rather
than after the fourth failed launch.

A vLLM-class server takes gpu-memory-utilization × total as its budget and
refuses to start when that exceeds the memory actually free. "Free" is smaller
than the MemAvailable a person reads — the kernel reserve, plus whatever is
already resident — and on a unified-memory part nvidia-smi cannot even report
the total. This command measures each node, sizes the model from the hub,
divides by the tensor-parallel width, and reports the highest utilisation each
node will accept and what is left for the KV cache at it.

EXACT NUMBERS

A failed launch prints the two figures the runtime itself used:

  Free memory on device cuda:0 (103.02/121.69 GiB) on startup is less than
  desired GPU memory utilization (0.88, 107.09 GiB)

Pass them with --free-gib 103.02 --total-gib 121.69 and the plan is exact
rather than estimated from the host's own view.

WHAT IT WILL NOT GUESS

Per-request KV cache needs the model's attention geometry, not its parameter
count: a generic estimate is off by two orders of magnitude on a large MoE.
Measure it once and pass --kv-per-request-gib to turn headroom into a
concurrency number.

```
fabric plan launch [model] [flags]
```

Examples:

```bash
fabric plan launch RedHatAI/GLM-5.3-Flash-NVFP4 --tp 2

# Exact, using the numbers a failed launch printed.
fabric plan launch RedHatAI/GLM-5.3-Flash-NVFP4 --tp 2 --free-gib 103.02 --total-gib 121.69

# A model the hub cannot size, and a measured per-request KV.
fabric plan launch local/my-model --size-gib 88.6 --kv-per-request-gib 2.05
```

| flag | default | description |
|---|---|---|
| `--free-gib` | `0` | free memory the runtime reports, from a failed launch's message |
| `--json` | `false` | JSON output |
| `--kv-per-request-gib` | `0` | measured KV cache for one request at your context length |
| `--nodes` | `—` | comma-separated node names (default: every GPU node on the network) |
| `--overhead-gib` | `0` | per-rank runtime overhead beyond weights and KV (default 10) |
| `--size-gib` | `0` | model size on disk, when the hub cannot be asked |
| `--total-gib` | `0` | total memory the runtime reports, from a failed launch's message |
| `--tp` | `0` | tensor-parallel width the weights are split across (default: the number of nodes) |
| `--wait` | `1m30s` | how long to wait for nodes to report their memory |

### `fabric router`

Model router recipes

```
fabric router
```

### `fabric router init`

Model router recipes

Apply a router recipe: print the local setup plan and register the resulting
private service on this machine's mesh entry.

The steps are PRINTED, not run. Fabric shows you the commands (a docker run, a
health check) and you run them on the host; it does not execute a recipe's shell
on your behalf. What it does for real is publish the service, so peers can reach
it through the capability-gated forwarder.

ARGUMENT

  [name]    which recipe to apply. Built in: litellm, openai-compatible
            Plus any manifest in ~/.fabric/recipes.

WRITING YOUR OWN

Drop a YAML file in ~/.fabric/recipes. A manifest whose category and name match a built-in
REPLACES it, which is how you change an image or the arguments a runtime starts
with without waiting for a release:

  # ~/.fabric/recipes/my-runtime.yaml
  name: my-runtime           # what you pass to: fabric router init my-runtime
  category: router
  summary: One line shown when the recipe is applied.
  requires: [docker]         # printed as a prerequisite, not checked
  steps:
    - name: start
      run: "docker run -d --name my-runtime -p 127.0.0.1:18100:8000 my/image"
      check: "curl -sf http://127.0.0.1:18100/health"
  service_kind: router
  service:
    name: my-runtime
    kind: router
    addr: "127.0.0.1:18100"  # MUST be loopback — see below
    scope: "router:invoke"

The published address must be loopback (127.0.0.1 or localhost). A recipe may
only publish services on the machine applying it; peers reach them through the
mesh forwarder, which re-checks the capability. A manifest pointing anywhere
else is rejected with the reason, and a manifest fabric cannot read is named
rather than skipped in silence.

```
fabric router init [name]
```

Examples:

```bash
# Apply a built-in recipe.
fabric router init litellm

# Apply one you wrote yourself (~/.fabric/recipes/my-runtime.yaml).
fabric router init my-runtime
```

### `fabric stage`

Plan how large artifacts reach every node

```
fabric stage
```

### `fabric stage image`

Pull a container image with resumable, verified downloads

Pull a container image the way a large download has to work: each blob fetched
with a range request that continues where the last attempt stopped, each one
checked against its digest before it is trusted, and the result written as an
OCI layout that `docker load` accepts.

This exists because docker pull restarts a layer it fails to finish. On a slow
or unreliable link a multi-gigabyte layer then never completes, however long
you leave it — and the bandwidth is spent either way.

Re-running continues: blobs already on disk are checked, not fetched again.
The tar it produces is also the thing to copy to your other nodes, which is
far cheaper than every node pulling the same image.

Private images are not supported: no docker credentials are read.

```
fabric stage image [reference] [flags]
```

Examples:

```bash
fabric stage image ghcr.io/org/vllm:sm121-v11
fabric stage image ghcr.io/org/vllm:sm121-v11 --load
fabric stage image alpine:3.20 --platform linux/amd64 --out /tmp/alpine.tar
fabric stage image ghcr.io/org/vllm:sm121-v11 --plan
```

| flag | default | description |
|---|---|---|
| `--dir` | `—` | working directory for the OCI layout (default: under the fabric config dir, so a re-run resumes) |
| `--load` | `false` | run `docker load` on the result |
| `--out` | `—` | where to write the tar (default: beside the working directory) |
| `--plan` | `false` | report the size and layers, download nothing |
| `--platform` | `—` | os/arch to pull (default: this machine's) |

### `fabric stage model`

Work out whether to download a model on every node or copy it between them

Size a model, measure the link between your nodes, and say which way of getting
it onto all of them is faster — usually by two orders of magnitude.

Downloading a large repository separately on every machine means downloading it
separately on every machine. The link between two machines in the same rack is
routinely a hundred times faster than either one's route to the internet, and a
long download that stalls and restarts is worse than its average rate suggests.

It also checks that the destination has room. Running out of disk is the one
staging failure that arrives hours in, rather than immediately.

This prints a plan and the exact commands. It does not move the bytes: rsync
over ssh is better at resumable bulk transfer than anything here would be, and
it is already on both machines. What was missing was the decision, not the copy
tool.

```
fabric stage model [model-id] [flags]
```

Examples:

```bash
fabric stage model RedHatAI/GLM-5.3-Flash-NVFP4
fabric stage model RedHatAI/GLM-5.3-Flash-NVFP4 --from spark-worker --to spark-head
fabric stage model local/private-model --size-gib 184.3
```

| flag | default | description |
|---|---|---|
| `--from` | `—` | node that already has it, or will download it (default: the one with the most free disk) |
| `--json` | `false` | JSON output |
| `--size-gib` | `0` | model size on disk, when the hub cannot be asked |
| `--to` | `—` | node to copy it to (default: every other node) |
| `--wait` | `1m30s` | how long to wait for nodes to report disk |

## Maintenance

### `fabric update`

Update fabric (and the node agents) to the latest release

Download, verify (sha256) and replace the fabric CLI and its background
agents in place. Use --check to see what's available without installing.

```
fabric update [flags]
```

| flag | default | description |
|---|---|---|
| `--channel` | `stable` | release channel: stable, beta, or nightly |
| `--check` | `false` | only report whether an update is available |
| `--force` | `false` | reinstall even if already up to date |
| `--version` | `—` | install a specific version (e.g. v0.2.0) instead of the channel latest |

### `fabric version`

Print the fabric CLI version

```
fabric version
```

