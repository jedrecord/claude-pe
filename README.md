# claude-pe

A planner-executor workflow with model routing for Claude Code.

## The Intent

The intent behind this workflow is to generate reliable code and tests by
breaking the workflow apart into separate domains of expertise that specialized
agents can accomplish. An added benefit of this planner-executor workflow is
that each specialized agent can operate using an AI model appropriate to the
task. The hypothesis is that this will reduce the overall expense of token use
even if additional tokens are consumed by the extra checks built-in to the
workflow.

CAVEAT: Don't get hung up on the workflow, this is just an example that works
for me. It could be made much simpler, or more complex, if needed.
The main ideas are that you can use an advanced model to plan and delegate,
and less expensive models to execute, reducing the premium token expense.
The model proxy router allows you to save even more, by using open-weight or
even free models for executing agent tasks where less intelligence is needed.

## Model proxy router

This project provides a startup script and configuration files to run a model
proxy router to intercept Claude Code's model calls and substitute alternative
models hosted locally or online (like openrouter.ai).

Models are defined for each agent in the frontmatter and the proxy should match
this name exactly when routing to an alternative. I've found it's best to use
only valid Anthropic model names (e.g., opus, haiku, sonnet) to avoid issues if
you choose to switch between custom routing and default Anthropic.

I recommend having a look at the included
[example configuration](proxy/configs/example-proxy-config.yaml) to see the
mapping.

## The Orchestrator

"Hal" is an orchestrator that acts as the single point of contact for all
requests and routes every task to a team of specialized sub-agents instead of
doing substantive work itself.

## Core Guardrail

The orchestrator focuses on planning and does little substantive work directly.
Tasks are delegated to appropriate team members. If no suitable team member exists,
the orchestrator can run the [create-agent skill](team/skills/create-agent.md)
to define a new specialist agent.

The one carve-out: routing decisions and upkeep of the team's own configuration
(the roster, agent definitions, these instructions) are the orchestrator's own
work — delegating them would be circular.

## Quick start

Make sure litellm is installed
```bash
uv tool install litellm
```

The quickest way to start is with an openrouter API key
```bash
export OPENROUTER_API_KEY="sk-or-xxxxxxx"
```

Copy one of the configs in proxy/configs to ~/.config/litellm/config.yaml
```bash
mkdir -p ~/.config/litellm
cp proxy/configs/split-nemo.yaml ~/.config/litellm/config.yaml
```

Run the provided claude-proxy.sh start script
```bash
./scripts/claude-proxy.sh
```

## How It Works

1. **Receive** — a task comes in.
2. **Assess** — the orchestrator picks the best-suited team member, or decides
   a new agent is needed.
3. **Delegate** — the task is dispatched to that agent.
4. **Report** — the orchestrator relays the result back with a concise
   summary.

## Team Roster

| Agent | Role |
|---|---|
| **Rachel** | Senior Researcher |
| **Devon** | Developer |
| **Quinn** | QA Engineer |
| **Revan** | Code Reviewer |
| **Judy** | Completeness Verifier |
| **Karen** | Critic & Red Team Analyst |
| **Albert** | Senior Advisor |

Full routing detail, including when to route to each agent and "not for"
exclusions, lives in [team/team_roster.md](team/team_roster.md). Individual
agent behavior is defined in [team/agents/](team/agents/).

## Default Workflow

Unless overridden for a specific task, substantive work follows:

1. **Research** (Rachel) — establish facts and scope when the domain is
   unknown.
2. **Build** (a developer) — implement against a stated spec.
3. **Review** (Revan) — every diff is checked against its spec before
   shipping.
4. **Verify** (Quinn) — an executed test pass with a PASS/FAIL verdict on test
   results.

Karen (critique), Albert (advice), and Judy (completeness verdict) are not
pipeline stages — they're injected at decision points per the trigger rules in
[team/orchestrator-instructions.md](team/orchestrator-instructions.md). Work
isn't reported as done until review and verification have run and Judy has
confirmed the task is actually complete, unless the human explicitly waives
them.

## Repo Layout

```bash
CLAUDE.md                       — points Claude Code at the orchestrator instructions
team/
  orchestrator-instructions.md  — Hal's full operating instructions (source of truth)
  team_roster.md                — routing table summarizing agent behavior
  agents/                       — one definition file per team member
    albert.md
    devon.md
    judy.md
    karen.md
    quinn.md
    rachel.md
    revan.md
  skills/
    create-agent.md             — process for defining and registering a new agent
scripts/
  claude-proxy.sh               — starts a local LiteLLM proxy and launches `claude` against it
proxy/configs/                  — LiteLLM routing config profiles mapping agent model names to Anthropic/OpenRouter/local backends
```

The `claude-proxy` script/config route each agent's configured model (e.g.
`claude-haiku-4-5-20251001`) through a local LiteLLM proxy to the appropriate
backend (Anthropic, OpenRouter, or local), with fallbacks configured for
rate-limited models.

## Adding a New Team Member

Follow the [create-agent skill](team/skills/create-agent.md): it gathers the
role's context from the human, has Rachel profile the relevant domain expertise,
drafts the agent definition, writes it to `team/agents/<name>.md`, and registers
it in `team/team_roster.md` (and `team/orchestrator-instructions.md` if it
changes a delegation rule).
