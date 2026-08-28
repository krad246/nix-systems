# Dendritic context proxy

This repository is in a long-running Dendritic architecture migration. Do not
begin architectural work from this compact proxy alone.

Canonical context proxy SHA-256: `0336adbe0ac9058f34788a2ecc67db5b587bcefb04e18fdeea55c2fcbee73fd3`

Run:

```sh
.agents/dendritic/context.sh verify
.agents/dendritic/context.sh list
```

The agent shell exposes the same read-only invariant as both a command and a
scoped pre-commit hook:

```sh
nix develop .#agent -c verify-dendritic-context
nix develop .#agent -c pre-commit run verify-dendritic-context --all-files
```

Then lazily load the relevant routes, for example:

```sh
.agents/dendritic/context.sh read mission architecture hm next
```

Mandatory full expansion:

```sh
.agents/dendritic/context.sh full
```

Use full expansion before changing architecture, defining a migration/commit
plan, editing the context bundle, rebasing, deleting legacy modules, resolving
an ambiguity across lanes, or claiming a migration gate is complete. Targeted
route expansion is only for bounded implementation work after the full context
has already established that work's scope.

The canonical source is `.agents/dendritic/context.md`; `routes.tsv` is its lazy
index. After changing either, run `.agents/dendritic/context.sh refresh` and
commit the canonical files, manifest, and regenerated root `AGENTS.md` together.
A verification mismatch means this proxy is stale: stop and refresh or inspect
the canonical diff. Never reconstruct intent from the hash itself.

Local Codex project-charter caches are mirrors, not an authority. `refresh`
also updates them. After cloning or pulling on another computer, run
`.agents/dendritic/context.sh sync-cache` and `verify-cache`. Never leave a
cache-only architectural mutation: reconcile it into the canonical bundle,
refresh, verify, commit, and push it for the next machine/model to consume.
During long sessions, periodically make this canonical checkpoint so an
out-of-file-descriptors cache flush or process restart resumes from recent
committed context rather than conversation memory.
Use `nix run .#agent-checkpoint` as the stable checkpoint entry point. Its name
is independent of the current Dendritic storage so the mechanics can evolve.
Bounded checkpoint, propagation, cache verification, and isolated validation
may be delegated asynchronously when shared-file ownership is non-overlapping.
For bootstrap tooling, close over immutable logic/tools through Nix, late-bind
the writable workspace via explicit argument or local discovery, validate it
before mutation, and preserve a baseline-shell recovery path without devshell
or PATH assumptions. Inherit environment roots only when the tool's state
contract explicitly requires them.
Exported environment is an implicit process-tree software bus; publish onto it
only for an intentional consumer contract, otherwise keep state shell-local.
Nix-direnv bootstraps a cold worktree automatically, then reload is
intentionally manual to avoid reload churn; Lorri remains an exploratory
asynchronous shell-state publisher, not settled bootstrap policy.
Parallel agents own distinct worktrees and branches; verify the remote tip and
publish with `git push --force-with-lease --atomic`, never to a shared branch.
Legacy Generic Linux behavior is decision evidence, not automatic parity scope:
inventory and classify deltas, then require owner retain/redesign/drop decisions.
Kitty is a backend candidate for a multi-backend terminal interface, not the
portable interface itself.
VS Code and VS Code server integration are deferred outside current migration
scope and are not parity or deletion gates.

Owner decisions that pivot architecture must be synchronized immediately. Load
the `decision-sync` route, update every affected canonical statement/ledger/gate,
refresh and verify the proxy, and commit the bundle. Conversation, goals, and
model memory are not sufficient durable records.

Work as the owner's senior implementation contractor. The owner controls
requirements and accepted tradeoffs; the agent controls investigation,
technical execution, and proof. For genuine requirement ambiguity, load
`collaboration` and ask evidence-backed questions with alternatives,
consequences, and a recommendation. Load `invariants` before defining public
capability boundaries. Load `proof-budget` before rechecking a downstream fact
already guaranteed by platform, overlay, input, or interface composition. Load
`rootfs` whenever owner feedback teaches a durable new reasoning or
collaboration rule.

Current north star: fully and severably land the low-level Home Manager layer,
push genuinely user-space `nixbook-pro` behavior into it, and prove it with two
real consumers—nix-darwin-integrated HM and standalone HM—before hardening the
less-mature high-level interfaces. A coexistence bridge on current `main` is a
mandatory early deliverable: use it to move the epic to trunk-based incremental
ports rather than growing another unmergeable Dendritic branch.

Treat flake policy as repository execution policy and terraform the lock graph
incrementally: use meaningful flake-parts partitions, remove inputs only after
their consumers migrate, deduplicate with explicit follows, and require each
lock change to correspond to a proven output/capability boundary.

The frozen predecessor may be deliberately thawed to repair code it still
owns, then verified, re-pinned, and frozen again. Do not duplicate a capability
into the bridge merely to carry a repair. This main-based migration line owns
the sole policy bundle; predecessor-local copies are stale and must be removed.
Publish frozen/protected branch repairs as final PRs and wait for owner approval
and merge; move the associated freeze tag only after that approved merge.
Keep active migration/thaw work in dedicated temporary worktrees until the
bridge is fully eliminated; remind the owner of this preference before an early
move into their primary checkout, while allowing an explicit override.
