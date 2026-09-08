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

Managed runtime starts are intentionally limited to known Docker profiles in the
MVP. Arbitrary recipe shell execution is disabled until signed recipe provenance
and desired-state deployment jobs land.

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
