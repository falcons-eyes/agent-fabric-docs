---
title: Local Agent Stack
description: Run customer-owned local model servers, verify them, and use Agent-Fabric's local session runner without sending prompts or outputs to the cloud.
sidebar:
  order: 7
---

Agent-Fabric's Agent Stack is a local management plane for customer-owned AI runtimes.
It discovers or starts model servers, records local agent sessions, and exposes
operator controls for long-running loops. The Agent-Fabric control plane coordinates
identity, desired state and service discovery; prompts, model outputs, database
payloads and application logs remain on the customer node.

## What Agent-Fabric Does And Does Not Run

Agent-Fabric does not vendor Ollama, vLLM, MLX, Python environments or model weights.
The MVP boundary is:

- Linux/NVIDIA GPU hosts can use Agent-Fabric-managed Docker profiles for audited
  `vllm-docker` and `ollama-docker` runtime starts.
- macOS Apple Silicon uses native Metal/MLX-capable local servers such as
  Ollama or vLLM-Metal, then attaches their localhost OpenAI-compatible API.
- Windows is attach-first: use native Ollama or another localhost endpoint, or
  use WSL2/Linux NVIDIA for managed GPU profiles.
- `aflocal` is localhost-only and stores runtime/session state under
  `~/.fabric`.

## Start The Local Management API

Build the binaries and run the Local Console backend:

```bash
make build
export PATH="$PWD/bin:$PATH"
aflocal
```

By default, `aflocal` listens on `127.0.0.1:3210`. It allows browser CORS only
from loopback origins (`localhost`, `127.0.0.1`, `::1`), so a local UI can call
`/local/*` without exposing the API to arbitrary websites.

## Discover And Attach A Native Runtime

On macOS or Windows, start your local model server first. For example, launch
Ollama, pull a local model, then attach it:

```bash
fabric agent discover
fabric agent attach mac-ollama \
  --url http://127.0.0.1:11434/v1 \
  --model llama3.2:latest
fabric agent status
```

`fabric agent discover` probes common localhost model endpoints:

- Ollama: `127.0.0.1:11434`
- vLLM/OpenAI-compatible: `127.0.0.1:18000`
- vLLM/OpenAI-compatible: `127.0.0.1:18001`

## Start A Managed Linux/NVIDIA Runtime

On Linux/NVIDIA hosts with Docker and NVIDIA Container Toolkit:

```bash
fabric agent doctor
fabric agent start --runtime vllm-docker --name dev-vllm
fabric agent start --runtime ollama-docker --name dev-ollama
fabric agent status
```

Managed runtime starts are intentionally limited to known Docker profiles. Fabric
never executes a recipe's shell on your behalf; a recipe prints its steps and you
run them.

### Pass arguments to the model server

Anything after a bare `--` goes to the runtime untouched:

```bash
fabric agent start --runtime vllm-docker --name tp2 -- --tensor-parallel-size 2
```

A model server's own surface — tensor and pipeline parallelism, KV transfer for
prefill/decode separation, quantization — is far larger than the handful of flags
the CLI mirrors, and mirroring it one flag at a time would always lag the runtime.
Anything the server accepts works.

These replace Fabric's built-in first-run defaults where they collide. A vLLM
container is opened with a deliberately small window (`--max-model-len 1024`, 20%
of the GPU) so a first run succeeds on a modest card; passing your own value for
one of those means yours, not a value you never asked for.

Arguments are passed as argv, never through a shell, and are appended after the
image — so they reach the model server and cannot reach Docker's own flags.

## Check What This Machine Can Run

Before pulling tens of gigabytes, ask:

```bash
fabric models search "qwen2.5"
fabric models show bartowski/Qwen2.5-7B-Instruct-GGUF
```

The table gives each quantization's memory need and a verdict:

| Verdict | Meaning |
|---|---|
| `fits` | needs at most 80% of VRAM — the headroom is for a KV cache that grows |
| `tight` | fits, with no room to grow |
| `runs, partly in RAM` | over the VRAM line, but layers can live in system memory. Slower, **not** impossible |
| `won't fit` | too big for the GPU and the memory behind it |

Two flags change the answer:

- `--context N` sizes the KV cache against an N-token window (default 8192). This
  is the term that scales with the *conversation* rather than the model, so a 7B
  that fits comfortably at 8K can be too big for the same card at 128K. Size
  against the context you intend to serve.
- `--vram N` sizes against N GB instead of auto-detecting, so you can ask about a
  machine you are not sitting at.

On unified-memory hardware (Apple Silicon, NVIDIA Grace/GB10) the pool is shared
with the CPU. Fabric reports it as unified and does not treat it as spare capacity
to offload into, because there is no second tier to offload to.

A model whose repo name carries no parameter count cannot be sized at all, and
says so rather than reporting `0.0 GB` — which would make every quantization look
like it fits.

`fabric host` reports the same machine's accelerators, including when a pool could
not be measured. A driver that will not report its size is a different fact from a
card with no memory, and the two are never collapsed.

## Add Your Own Recipe

The built-in recipes are a starting set, not the boundary. A manifest in
`~/.fabric/recipes/*.yaml` is loaded on top of them, and one whose `category` and
`name` match a built-in **replaces** it — which is how you change an image, or the
arguments a runtime starts with, without waiting for a release.

```yaml
# ~/.fabric/recipes/my-runtime.yaml
name: my-runtime           # what you pass to: fabric llm init my-runtime
category: llm              # llm | router | agent | endpoint | service
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
  addr: "127.0.0.1:18100"  # must be loopback
  scope: "llm:invoke"
```

```bash
fabric llm init my-runtime
```

The published address must be loopback (`127.0.0.1` or `localhost`). A recipe may
only publish services on the machine applying it; peers reach them through the
mesh forwarder, which re-checks the capability. A manifest pointing anywhere else
is rejected with the reason.

A manifest Fabric cannot read is named rather than skipped in silence — one typo
never hides the others. `fabric agent doctor` lists what loaded and what did not.

## Start A Runtime On Another Machine

The commands above run on the machine you are sitting at. To bring a runtime up
on a different node — the second box in a tensor-parallel pair, a GPU host you do
not have a terminal on — name it:

```bash
fabric agent start --node spark-2 --runtime vllm-docker --register --follow \
  -- --tensor-parallel-size 2
```

Same profile, same flags, same `--` passthrough. The node runs it and reports
back:

```
✔ queued on spark-2 — job_53cb4baf4eba3ff7
  status: applied
✔ started spark-worker (vllm-docker) at http://127.0.0.1:18000/v1, published as spark-worker
```

Without `--follow` the command returns as soon as the request is queued. A job
for a machine that is currently offline is not lost — it runs when that node next
polls.

`--follow` running out of time is **not** a failure. A cold host pulls a
multi-gigabyte image before the container starts, so "still pending" means still
working; check again with `fabric status`.

### What a remote start can and cannot ask for

This is a desired-state job, not a remote shell. The receiving node picks the
image, every Docker-level flag and the loopback port binding from **its own**
compiled-in profile. The request chooses which profile, and what to pass the
model server:

| Chosen by the node | Chosen by the request |
|---|---|
| the container image | which runtime profile |
| every `docker run` flag | model, served model name, port |
| the loopback port binding | the model server's own arguments |

There is no field that could ask for a different image, a bind mount, a
privileged container, or a port on a public interface. Both ends validate: the
control plane refuses a malformed request before it is stored, and the node
re-checks before executing.

A node whose build has no runtime manager reports the request **rejected** rather
than failed — "this machine cannot do that" is a different answer from "it tried
and broke".

## Verify Runtime Behavior

Run smoke checks before registering a model server for real use:

```bash
fabric agent smoke mac-ollama --loops 3
```

Required checks verify:

- streaming completions
- multi-turn conversation recall
- local memory injection
- durable loop checkpoint behavior

Optional capability checks record support for:

- `/v1/models`
- JSON mode
- tool/function calling
- embeddings
- `/v1/responses`

Optional capability failures do not fail the smoke command; they are recorded so
operators can see what a model server supports.

## Run A Long-Running Agent Loop

The local runner writes every step to a local session. It supports deterministic
step IDs, resume from checkpoint, cancellation polling, retry/backoff,
compaction/redaction and live session follow.

```bash
fabric agent loop mac-ollama \
  --steps 3 \
  --prompt "Continue the local maintenance task and report concise progress." \
  --redact
```

Inspect, follow, cancel or resume the session:

```bash
fabric agent session list
fabric agent session show <session_id>
fabric agent session follow <session_id>
fabric agent session cancel <session_id>
fabric agent loop mac-ollama --session <session_id> --steps 3
```

Compact older local context:

```bash
fabric agent session compact <session_id> \
  --summary "Compacted completed setup work" \
  --keep-last-events 20 \
  --redact-events \
  --redact-checkpoints
```

The model may fail to repeat the requested step ID exactly. Agent-Fabric treats the
controller-generated step ID as the source of truth and records whether the model
acknowledged it in session metadata.

## Local Console API Surface

The CLI above calls the same localhost API that the Local Console UI will use:

| Endpoint | Purpose |
|---|---|
| `GET /local/runtimes` | List Agent-Fabric-managed and attached runtimes |
| `GET /local/runtimes/discover` | Probe localhost model servers |
| `POST /local/runtimes/{name}/smoke` | Run workload and capability smoke checks |
| `POST /local/runtimes/{name}/loop` | Start or resume a long-running local loop |
| `GET /local/sessions` | List local agent sessions |
| `GET /local/sessions/{id}` | Read events and checkpoints |
| `GET /local/sessions/{id}/stream?follow=true` | Follow live session updates |
| `POST /local/sessions/{id}/cancel` | Mark a running session cancelled |
| `POST /local/sessions/{id}/compact` | Summarize and optionally redact local payloads |

The cloud control plane should receive only identity, version, desired state and
health metadata. Prompts, outputs, tool payloads and session details remain
local.

For every `fabric agent ...` command, including all flags and copy-ready examples,
see the generated [fabric CLI reference](/reference/cli/).
