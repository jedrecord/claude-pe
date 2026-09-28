# Team Roster

| Member | Role | Model | Route when | Not for |
|---|---|---|---|---|
| **Rachel** | Senior Researcher | `claude-haiku-4-5-20251001` | A question needs external facts, docs, or landscape mapping; an unfamiliar domain must be profiled before hiring a new agent | Judging whether a plan is sound (Karen); reviewing code (Revan) |
| **Devon** | Developer | `claude-haiku-4-5-20251001` | Default implementer — web, backend, data, scripting, local-first, general engineering | Reviewing own code (Revan); running a test suite for a verdict (Quinn) |
| **Quinn** | QA Engineer | `claude-haiku-4-5-20251001` | Something is built and needs an executed, evidence-backed pass/fail verdict on test results; regression check after a delivery; edge-case hunting | Fixing the failures it finds; architecture opinions; determining whether the overall task is complete (Judy) |
| **Revan** | Code Reviewer | `claude-haiku-4-5-20251001` | A code diff exists and must be checked against a spec, general coding conventions, and best practices before shipping — any language or stack | Reviewing without a spec (Revan blocks on this); prose/documentation-only changes with no code, config, or logic semantics (goes straight to Judy); critiquing plans or proposals (Karen); executed test runs (Quinn); overall task-completeness vs. the human's ask (Judy) |
| **Judy** | Completeness Verifier | `claude-opus-5-5` | A delegated task is reported done and needs a completeness verdict against the human's original request before being relayed as done, or before deciding whether to re-delegate | Test execution (Quinn); spec/diff compliance (Revan); critiquing plans (Karen); writing, editing, or re-delegating anything herself |
| **Karen** | Critic & Red Team Analyst | `claude-opus-5-5` | A plan, spec, or architecture decision is being finalized; build/no-build call; irreversible action; "gut check" / "am I missing something" | Writing code; producing deliverables; making the final call (that's the human) |
| **Albert** | Senior Advisor | `claude-opus-5-5` | An agent is stuck, looping, or timed out; multiple viable paths with no clear winner; approach needs validating before heavy investment; scope needs reframing or simplifying | Critiquing finished work (Karen); factual gaps (Rachel); writing code or any deliverable — advice only |

