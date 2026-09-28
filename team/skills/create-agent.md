---
name: create-agent
description: Creates a new AI team member for the orchestrator. Gathers the role's context from the human, has Rachel profile the domain expertise, then drafts and registers the new agent definition.
---

# Create Agent Skill

Use this skill when a task's domain is not covered by the existing team and a specialized agent would do the work better than a generalist. Do not use it for one-off tasks — those route to an existing agent or to Devon as generalist.

## Inputs to Gather First

Ask the human for the following before doing anything else. Do not assume plausible answers.

1. **Role** — what is this agent, in one line? (e.g., "Technical Writer", "Data Engineer")
2. **Domain** — what specific expertise separates this agent from a generalist developer or researcher?
3. **Deliverables** — what does this agent produce? What does it explicitly *not* produce?
4. **Routing triggers** — when should the orchestrator route to this agent, and when should the orchestrator route elsewhere instead?
5. **Model** — which model should run it, or should the orchestrator recommend one?

If the human answers "you decide," recommend based on the domain (see Model Selection below) and get confirmation before creating.

## Workflow

1. **Gather inputs** from the human (above). Do not skip to drafting.
2. **Dispatch Rachel** to profile the domain: what real-world experts in this field actually do — key skills, thinking patterns, daily tools, common pitfalls, and what separates great practitioners from average ones. Ask for behaviors and judgment calls, not just knowledge.
3. **Draft the agent definition** from Rachel's profile, following the structure of the existing agents in `team/agents/` (see rachel.md or quinn.md as templates):
   - Frontmatter: `name` (one-word human name, no collision with existing members), `description` (one line: role + specialty), `model`
   - Sections: Identity, Role, Workflow, Guidelines
   - Always include the standard escalation rule: "If you get stuck, start looping, hit a timeout, or need direction you don't have — stop and report back to the orchestrator with what you tried and where you're blocked. Do not spin."
4. **Write** the definition to `team/agents/<name>.md` (lowercase filename).
5. **Register the agent**:
   - Add a row to the routing table in `team/team_roster.md` (Member, Role, Model, Route when, Not for)
   - Update the Delegation Rules in `team/orchestrator-instructions.md` if the new agent takes over a routing rule from an existing member
6. **Report back to the human** with the new agent's name, one-line role, model, and routing trigger summary.

## Model Selection

When the human asks the orchestrator to pick:

- Routine execution, well-scoped work → `claude-haiku-4-5-20251001` (team default)
- Judgment-heavy, high-stakes, or adversarial roles → a stronger model (e.g., `claude-opus-5-5`), matching how Albert is configured
- Experimental or comparison slots → non-production models, flagged as such in the roster

## Constraints

- Never create an agent that duplicates an existing member's role — widen routing instead
- Never create an agent for a task Devon (or another generalist) handles adequately
- One agent per distinct domain; do not split a domain into multiple agents without the human's say-so
