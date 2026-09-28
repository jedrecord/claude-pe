# Routing model requests

## 1. Set LiteLLM as your Model Proxy Router

You need a local middleware service to translate Anthropic-formatted API
requests into OpenRouter requests, and map "valid" Anthropic model names to
your desired open-weight models. LiteLLM is the industry standard for this.

### Install and configure LiteLLM

Install LiteLLM globally using your package manager (e.g., `uv tool install
litellm` or `pipx install litellm`).

### Create the translation mapping

Create a config.yaml file for LiteLLM. Opus is the planning/orchestration
model and stays on Anthropic directly — it is never routed to an
open-weight substitute. The haiku slot, used by sub-agents, routes to a
real Qwen model on OpenRouter.

`~/.config/litellm/config.yaml`
```yaml
general_settings:
  forward_llm_provider_auth_headers: true

model_list:
  - model_name: claude-opus-5-5
    litellm_params:
      model: anthropic/claude-opus-5-5
      api_key: os.environ/ANTHROPIC_API_KEY
      api_base: "https://api.anthropic.com"
  - model_name: claude-haiku-4-5-20251001
    litellm_params:
      model: openrouter/qwen/qwen3.8-27b:free
      api_key: os.environ/OPENROUTER_API_KEY
      api_base: "https://openrouter.ai/api/v1"
```

### Start the proxy

Run the proxy server in the background:
```bash
export OPENROUTER_API_KEY="sk-or-v1-..."
litellm --config ~/.config/litellm/config.yaml --port 4000
```

## 2. Point Claude Code to our proxy

Claude Code relies on the official Anthropic SDK, which respects standard
environment variables. You must redirect its base URL away from Anthropic's
servers and toward your local proxy.

Before launching your Claude Code orchestrator, two environment variables
need to be set in your terminal session:

- `ANTHROPIC_BASE_URL` — point this at your local LiteLLM proxy
  (`http://localhost:4000`) instead of Anthropic's servers.
- `ANTHROPIC_API_KEY` — set this to a dummy value (e.g. `sk-dummy`). Claude
  Code requires a key to be present, but LiteLLM handles the real
  authentication with OpenRouter, so the value itself doesn't matter.

The combined launch script in step 4 sets both of these variables for you
automatically, so a separate script isn't needed here.

## 3. Update Your Agent Definitions

Because the proxy is now active, you continue to use standard Anthropic
model names in your agents.md frontmatter, but the proxy will silently swap
them out during execution.
For your Orchestrator (The Planner): Ensure the frontmatter is set to the
Opus model name you mapped in LiteLLM.
orchestrator-agent.md
```
---
name: orchestrator
model: claude-opus-5-5
---
```

worker-agent.md
```
---
name: worker
model: claude-haiku-4-5-20251001
---
```

Result: the proxy receives this request, intercepts it, translates the
payload, and executes the task using `qwen/qwen3.8-27b:free` on OpenRouter.
Opus itself is not substituted — it continues to route directly to
Anthropic; only the sub-agent-tier (haiku) model is routed to an
open-weight alternative.
By using this proxy architecture, Claude Code remains entirely unaware that
it is commanding Qwen 3.8 for its sub-agents. Your existing workflow, agent
manifests, and delegation logic require zero structural changes.

## 4. Putting it all together

This section puts it all together into a single start script that shuts
down the proxy when Claude Code exits.
proxy-claude.sh
```bash
#!/bin/bash

# 1. Verify your OpenRouter key is available
if [ -z "$OPENROUTER_API_KEY" ]; then
  echo "Error: OPENROUTER_API_KEY environment variable is not set."
  echo "Run 'export OPENROUTER_API_KEY=your_key_here' first."
  exit 1
fi

echo "Starting LiteLLM proxy..."

# 2. Start LiteLLM in the background and hide its output in a log file
# (Defaults to ~/.config/litellm/config.yaml — override the path below if
# your config is stored elsewhere)
litellm --config ~/.config/litellm/config.yaml --port 4000 > ~/.config/litellm/litellm.log 2>&1 &

# 3. Capture the Process ID (PID) of the last background command
LITELLM_PID=$!
echo "LiteLLM running on port 4000 (PID: $LITELLM_PID)"

# 4. Set a trap to kill the proxy automatically whenever this script exits
trap "echo 'Shutting down LiteLLM proxy...'; kill $LITELLM_PID 2>/dev/null" EXIT

# Give the proxy 2 seconds to initialize before Claude tries to connect
sleep 2

# 5. Point Claude Code to our proxy
export ANTHROPIC_BASE_URL="http://localhost:4000"
export ANTHROPIC_API_KEY="sk-dummy"

# 6. Run the orchestrator
claude $@
```
