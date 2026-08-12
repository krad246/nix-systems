# Dendritic context proxy

This repository is in a long-running Dendritic architecture migration. Do not
begin architectural work from this compact proxy alone.

Canonical context proxy SHA-256: `2cbc88532ec5f55ac69085ba1d0ba1052676e966a423eed431fd805623b347c4`

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

Owner decisions that pivot architecture must be synchronized immediately. Load
the `decision-sync` route, update every affected canonical statement/ledger/gate,
refresh and verify the proxy, and commit the bundle. Conversation, goals, and
model memory are not sufficient durable records.

Current north star: fully and severably land the low-level Home Manager layer,
push genuinely user-space `nixbook-pro` behavior into it, and prove it with two
real consumers—nix-darwin-integrated HM and standalone HM—before hardening the
less-mature high-level interfaces. A coexistence bridge on current `main` is a
mandatory early deliverable: use it to move the epic to trunk-based incremental
ports rather than growing another unmergeable Dendritic branch.
