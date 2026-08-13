# Dendritic context proxy

This repository is in a long-running Dendritic architecture migration. Do not
begin architectural work from this compact proxy alone.

Canonical context proxy SHA-256: `f9550df00d89e8ae8ec6df8cfa6798aa5f3ffe1f5c214e18f8147f0097820c19`

Run:

```sh
.agents/dendritic/context.sh verify
.agents/dendritic/context.sh list
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

The frozen predecessor may be deliberately thawed to repair code it still
owns, then verified, re-pinned, and frozen again. Do not duplicate a capability
into the bridge merely to carry a repair. This main-based migration line owns
the sole policy bundle; predecessor-local copies are stale and must be removed.
