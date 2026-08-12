# Dendritic migration: canonical operational context

Read this entire file before changing architecture, rebasing, deleting legacy
modules, or proposing a migration plan. This is both a project charter and an
operational handoff for future Codex/model versions. Do not reduce it to a
generic "modernize the Nix flake" task.

## Mission and stopping condition

The long-lived `dendritic` feature branch cannot land as one repository-wide
rewrite. Incrementally land its architecture on `main`, beginning with the full
logical closure of `nixbook-pro`, and leave a bridge on `main` through which
later sessions can port coherent slices from `dendritic` without repeating its
structural-rebase problem. Continue the epic until the remaining machine
closures have been migrated.

The immediate sequence is:

1. finish a behavioral and architectural diff of the complete old and new
   `nixbook-pro` closures;
2. polish the low-level Home Manager experience until it is independently
   landable and production quality;
3. derive an explicit dependency graph and concrete commit plan;
4. create a bridge commit on `main` that permits legacy and Dendritic structures
   to coexist;
5. port capability lanes and machine closures in coherent, verified commits.

The coexistence bridge is mandatory and urgent, not an optional cleanup after
the HM design is perfected. The migration cannot land without converting this
long-lived feature-branch effort into trunk-based incremental work. Do enough
closure analysis to design the bridge correctly, then land the bridge on
current `main` and route the polished HM slice through it. Do not continue
accumulating a second unmergeable architecture on `dendritic`.

The current highest-value landing hypothesis is a complete, correct, general,
and severable Home Manager substrate with two immediate consumers:

1. Home Manager integrated into `nixbook-pro` through nix-darwin;
2. a standalone Home Manager configuration.

Push as much of `nixbook-pro` as is genuinely user-space into this common HM
layer. The point is not to force system responsibilities into HM; it is to
isolate and prove the user-experience closure once, against two real
composition modes, before finishing the less-mature Darwin and host lanes.

Do not call the migration complete because `nixbook-pro` evaluates, because a
subset of tests pass, or because the branch is mergeable. Completion means the
architecture and subsequent machine ports described here are actually landed
and verified.

## Authoritative architectural intent

Systems are to be reconstructed from imports of capability interfaces, not
from host-shaped or platform-shaped implementation bundles.

Each capability owns a virtual module namespace. By convention the virtual
namespace has the same name as the module/capability. Treat the namespace as a
vTable:

- consumers program against the virtual interface;
- concrete backends are derived implementations beneath that interface;
- presets select implementations and defaults but are not interfaces;
- integrations implement relationships between two capabilities and should be
  separately severable where either endpoint can exist without the other.

For example, a picker consumer should request candidate production, preview,
view, or edit operations. It should not construct FZF commands. FZF is one
backend for the picker vTable; FD, Bat, and Helix integrations populate parts of
the contract. Likewise, a consumer of a browser should depend on the logical
browser/open operation, not directly on Zen or its installation mechanism.

The required properties are:

- interface declarations are severable from backend implementations;
- a backend can be replaced without editing its consumers;
- integrations are explicit and independently severable;
- disabling a backend removes its packages from the realized derivation
  closure;
- source, evaluation, and derivation closure are distinct concepts;
- evaluation scope should also remain lightweight, even where Nix laziness
  keeps a package out of the realized derivation closure;
- module composition remains transitively lightweight: importing a composition
  must not silently acquire unrelated capabilities;
- a virtual namespace corresponds to one stable atomic capability, not merely
  to a small file;
- host modules contain machine facts, explicit policy selections, and genuine
  exceptions rather than reusable implementations;
- platform modules dispatch or realize capability intent; they should not be
  the only place the intent can be expressed.

### Closure-discipline priority and accepted dispatch cost

Do not flatten every kind of minimality into one metric. The intended priority
is roughly:

1. **flake-input graph discipline**: ruthlessly deduplicate inputs, use explicit
   `follows`, use auto-follow machinery where appropriate, and prune unused lock
   nodes;
2. **derivation/runtime closure minimality**: disabled or unrelated
   implementations must not be installed or retained by the built result;
3. **module-level severability**: consumers, interfaces, implementations, and
   integrations must be independently composable at the correct capability
   boundary;
4. **evaluation minimality**: desirable, measured, and improved, but the lowest
   priority of these closure disciplines.

Some evaluation enlargement is the ordinary cost of vTable-like dispatch: the
evaluator may need the interface, variants, and visitor/dispatch trampoline
resident in memory so it can choose a backend. Do not contort a clean virtual
interface merely to eliminate this expected cost. Flag evaluation behavior
when it forces expensive inputs or implementation values unnecessarily, but
distinguish that from the acceptable residency needed to make variants
available for dispatch.

Input minimality is not optional just because evaluation minimality ranks
lower. The current Dendritic substrate deliberately uses `nix-auto-follow`,
explicit `inputs.*.follows`, empty follows where an upstream input is genuinely
unneeded, and `flake-file` lock pruning. Preserve this discipline and verify the
generated lock graph rather than accepting duplicate Nixpkgs/Home Manager trees
as incidental flake churn.

There is also a not-yet-realized ambition for flake-parts module-level
severability/applicability—ideas such as `importApplies` and related machinery.
Do not claim this exists today. Record cases where flake modules are resident or
applied too broadly so that a future substrate can make applicability explicit,
but do not block the HM landing on inventing the entire mechanism first.

Atomicity is semantic. A 150-line backend may be one correct capability. Ten
five-line files are still a monolith if they always activate together or can
only be consumed as a bundle.

### Profiles

Profiles are intentionally opinionated presets. They compose through imports
and enable/default declarations, ordinarily using `mkDefault` so callers can
replace selections. Do not criticize a profile merely for choosing Bash,
Helix, FZF, Kitty, or Zen. Do flag a profile if selecting one intended lane
activates unrelated capabilities or prevents backend substitution.

Keep these categories conceptually distinct:

1. interface modules define vTables/contracts;
2. backend modules realize a contract;
3. integration modules connect contracts;
4. profiles/presets import coherent capability sets and select defaults;
5. hosts supply machine facts and exceptional policy.

The highest-level interfaces and presets are expected to be the least mature.
Do not prematurely freeze them merely to make the current tree look finished.

### First polished landing: low-level Home Manager

The shell work establishes the intended pattern even though its feature set is
not finished. The first production-quality landing should be the low-level Home
Manager substrate: shell, picker, programs, editor, terminal, identity/secrets,
and their backends and integrations. High-level browser, application-store,
dock, desktop, and final workstation taxonomy can remain exploratory while this
substrate is stabilized.

For the HM substrate, require at least:

- interfaces that do not select implementations;
- backend `enable` separate from `default` where multiple active backends or a
  default role are meaningful;
- integrations that do not unexpectedly enable both endpoints;
- disabled backend packages absent from derivation closures;
- backend-only package universes, including unstable Nixpkgs, not forced merely
  by interface availability where practical;
- minimal, interactive, development, and standalone compositions tested
  separately;
- the same capability modules usable by standalone HM and system-integrated HM;
- no consumer knowledge of FZF/Helix/Kitty/etc. when a logical contract is
  sufficient.

## `ezConfigs` and flake composition

`ezConfigs` is legacy infrastructure, not a migration target. It was useful on
`main` because it discovered host/home modules and coupled user Home Manager
modules into system configurations. Dendritic composition makes that machinery
unnecessary and it is not a good architectural fit.

Do not preserve, port, wrap, or recreate `ezConfigs` merely for compatibility.
Its old behavior must be understood when calculating the old logical closure,
but the new system should express that behavior directly through virtual
modules and imports.

Do not assume another existing flake-parts host/configuration interface is the
desired replacement. None is currently known to fit this architecture well.
`flake-parts` may still provide the flake module substrate, and `flake-file` plus
`import-tree` currently provide generated-input and Dendritic module discovery,
but host composition belongs to the project's own capability modules.

## Branch topology and migration hazard

At the time this handoff was written:

- working branch: `dendritic` at `5940c9bf` before this handoff commit;
- remote tracking branch: `origin/dendritic` at the same commit;
- `main` at `315488c2` in the primary repository branch listing;
- a separate worktree at `./main` is on `general-longstanding-cleanup` at
  `6e2ecfb4` and must not be mistaken for the `main` branch;
- merge base between `main` and `dendritic`: `f851783b`;
- `dendritic` was reconstructed through roughly one hundred small sequential
  commits, beginning with `Clean everything out` and rebuilding the flake and
  modules from a blank baseline.

Always re-check these facts. They are historical coordinates, not permanent
truth. Use `git status --short --branch`, `git branch -vv`, `git worktree list`,
and `git merge-base main dendritic` before acting.

The branches also differ in dependency era. Current `main` has moved to 26.05
inputs in its generated flake, while `dendritic` currently uses 25.11 for
Nixpkgs, Home Manager, and nix-darwin. Never treat lockfiles or generated
`flake.nix` as mechanically interchangeable. Do not solve this with a giant
rebase. The bridge must make coexistence and incremental ports possible.

The Dendritic branch's broad diff (previously measured as 475 files, about 6,374
insertions and 12,402 deletions) is a consequence of reconstruction, not a
reasonable landing unit. Avoid deleting unrelated legacy hosts or modules as a
side effect of landing `nixbook-pro`.

## Correct definition of the old `nixbook-pro` logical closure

Do not inspect only `configurations/darwin/nixbook-pro`.

On `main`, `flakeModules/ezConfigs/flake-module.nix` declares:

```nix
ezConfigs.darwin.hosts.nixbook-pro.userHomeModules = ["krad246"];
```

That injects `configurations/home/krad246.nix` into the host. The old logical
closure therefore contains both:

1. direct Darwin roots:
   - `configurations/darwin/nixbook-pro/default.nix`;
   - `configuration.nix`;
   - `remotes.nix`;
   - Darwin `apps`, `base-configuration`, `colima`, `macos-container`, and
     `tailscale` imports;
2. the user HM root:
   - `configurations/home/krad246.nix`;
   - `homeModules.base-home` and every transitive import;
   - generic Cachix, Nix core, flake registry, and home-link registry modules.

The old host also adds a host-local HM import enabling Codex from unstable.

Trace actual option definitions and the merged module result. Similar filenames
or namespaces are not evidence of behavioral parity.

## Current Dendritic `nixbook-pro` root and composition

`modules/hosts/nixbook-pro/configuration.nix` creates
`flake.darwinConfigurations.nixbook-pro` and imports:

```text
darwin.workstation
├── darwin.applications
├── darwin.base
│   ├── home-manager
│   ├── input-registry
│   ├── nix
│   ├── nixpkgs-instance
│   └── owner
├── darwin.desktop
│   ├── app-stores
│   ├── browser
│   └── homeManager.desktop for owner
├── darwin.dev
│   └── homeManager.dev for owner
└── darwin.secrets
    └── homeManager.secrets for owner

darwin.linux-builder
darwin.tailscale
host-specific inline modules
```

The owner HM composition reaches:

```text
homeManager.base
├── identity
├── input-registry
└── shell

homeManager.desktop
├── browser
└── terminal

homeManager.dev
├── editor
└── shell.profiles.dev

homeManager.secrets
└── RBW backend
```

The host-specific inline modules currently own the aarch64-darwin platform,
hostname, UID/GID, Bash login shell, DNS/network naming, Nix daemon exceptions,
deep-cache tuning, trusted owner, Touch ID, macOS updates, and Linux-builder VM
sizing.

## Strongest architectural results so far

### Shell/picker/program composition

This is the reference pattern. Important layers include:

- `shell.profiles.interactive` and `shell.profiles.dev`: preset policy;
- `shell.programs.*`: logical tool capabilities;
- `shell.backends.bash` and `.nushell`: concrete shells;
- `picker`: logical sources, actions, and bindings;
- `picker.backends.fzf`: concrete picker;
- narrowly scoped integrations such as FZF-FD, FZF-Bat, FZF-Helix,
  Delta-Git, Delta-Lazygit, Git-GH, Git-Kitty, Bash-Yazi, etc.

The picker interface's sources/actions are a better boundary than exposing FZF
command fragments to consumers. Preserve and extend that pattern.

There are still rough edges. Some program modules are aliases directly onto HM
`programs.*.enable`, the shell base wires many defaults, and package/evaluation
laziness has not been systematically proven. Treat shell as the pattern source,
not as finished code immune from audit.

### Remote Linux builder

The old `base-configuration/linux-builder.nix` combined public options,
nix-darwin realization, guest NixOS configuration, binfmt, ccache, packages,
swap, TERM, coredumps, and VM sizing.

The current structure separates:

- `remoteBuilder`: generic interface;
- `remoteBuilder.backends.linux-builder`: Darwin/nix-darwin backend;
- `nixos.remote-builder`: reusable guest preset;
- host-provided `remoteBuilder.configuration`: deferred guest overrides.

This is architecturally strong and demonstrates composition across a nested
system boundary. Functional parity remains unproven and must cover advertised
systems, binfmt, ccache, swapspace/static swap, zram, VM cores/RAM/disk,
maxJobs, TERM, bottom, coredumps, and protocol.

## Explicit owner decisions: do not reopen without new direction

- Arc is removed.
- LaunchControl is removed.
- Zen is retained.
- Discord is added.
- Colima is intentionally excluded from this port.
- `macos-container` is intentionally excluded from this port.
- Using Nixpkgs `bashInteractive` instead of the Homebrew Bash is acceptable for
  the narrowed slice.
- Homebrew itself is not forbidden. It may remain or return behind a sound
  capability; it was initially narrowed out because of porting friction.
- Profiles are presets and may compose through imports and enable/default
  declarations.

## Explicitly unfinished or exploratory areas

Do not mistake existence for endorsement:

- remote definitions for `dullahan`, `gremlin`, and `fortress` are missing
  because their lane still needs rearchitecture; their disappearance is not an
  accepted feature removal;
- `appStore` has had effectively zero serious interface-design thought and is
  exploratory;
- browser and related high-level interfaces are exploratory;
- dock may be half-baked;
- the highest-level profiles/interfaces are generally the least baked;
- evaluation-scope enlargement is known and should be recorded, prioritized,
  and fixed after/alongside derivation-closure correctness;
- every old `base-configuration` behavior must be checked explicitly.

Do not expend early work defending or polishing app-store/browser/dock APIs as
if they were settled. First use closure evidence to determine their correct
capability boundaries.

## Behavioral parity ledger (evidence as of this handoff)

Status meanings:

- **preserved**: evidence establishes equivalent effective behavior;
- **static match**: source mappings look equivalent, but evaluated output still
  needs proof;
- **accepted change**: owner explicitly accepts the difference;
- **missing**: legacy behavior is in the old closure and has no current
  realization;
- **unverified**: replacement exists but parity is not proven;
- **irrelevant**: old module contributed no active behavior;
- **superseded**: a deliberately different capability fulfills the intent, with
  details still subject to parity audit.

### Host and Darwin base

| Legacy responsibility | Status | Current evidence / required follow-up |
|---|---|---|
| macOS automatic updates | preserved | Set directly in current host. |
| hostname, localHostName, computerName | preserved | Set from `networking.hostName`. |
| Cloudflare and Google IPv4/IPv6 DNS | preserved | Same values set by host. |
| `NIX_REMOTE=daemon` | preserved | Set by host. |
| `auto-allocate-uids=false` | preserved | Set by host. |
| `auto-optimise-store=false` | preserved | Set by host. |
| `/nix/store` extra sandbox path | preserved | Set by host. |
| `keep-derivations=true` | preserved | Set by host. |
| `max-substitution-jobs=60` | preserved | Set by host. |
| owner UID/GID 501/20 | preserved | Host sets user IDs. |
| primary owner, description, home | static match | `darwin.owner` supplies these; evaluate final user record. |
| trusted owner | preserved | Host sets `nix.settings.trusted-users`. |
| Touch ID for sudo | preserved | Set by host. |
| nixbld GID 350 | preserved | Current `darwin.nix`. |
| system Agenix module and custom Agenix package | missing | `darwin.secrets` only bridges HM RBW; it does not import `darwin.agenix` or install the prior tool. Decide desired system/HM secret capabilities. |
| firewall | irrelevant | Old file contained comments only. |
| system terminal fonts | missing | Old `fonts.packages = pkgs.krad246.term-fonts.paths`; no equivalent found in current host cone. |
| HM bridge package universe | changed/unverified | Old had `useGlobalPkgs=true`, `useUserPackages=true`, `verbose=false`; new leaves global pkgs off, uses user packages, and is verbose. Audit package identity/overlays/unfree effects before choosing policy. |
| Homebrew substrate | changed/unverified | Old imported nix-homebrew but defaulted it and Homebrew off, still added `mas` and prefix/shell declarations. Current app-store selection activates Homebrew. Compare effective behavior, not declarations. |
| guest login disabled | missing | Old master-user module set `GuestEnabled=false`; current lock-screen modules are empty. |
| console access disabled | missing | Old set `DisableConsoleAccess=true`; no current realization found. |
| screensaver password | missing | Old set `screensaver.askForPassword=true`; current screensaver module is empty. |
| custom preference dispatch | unverified | Old copied `CustomUserPreferences` to `CustomSystemPreferences`; new HM Darwin target writes domains through `targets.darwin.defaults`. Compare generated activation/defaults behavior. |
| dark mode | static match | New desktop defaults request dark, nonautomatic style. Evaluate. |
| Finder settings | static match | Hidden/extensions, desktop, search scope, view, trash cleanup, path/status bars, POSIX title, folders-first are mapped. |
| menu/dialog preferences | static match | Expanded save/print panels, table mode, visible menu bar mapped. |
| pointer/trackpad | static match | Flat mouse acceleration, non-natural scrolling, right-click, corner/scaling values represented. |
| Spotlight order | static match | Same explicit ordered list exists in Darwin HM dispatcher. |
| window manager/spaces | mostly static match | Old values represented; evaluate exact domains/types. |
| Dock constants | mostly static match | Old autohide, magnification, tile size, corners, recents, etc. represented. |
| Dock apps | partial | Old pinned iPhone Mirroring + Launchpad, and host prepended Zen. New defaults request logical browser, phone-mirroring, launchpad, file-manager, terminal, editor. Darwin dispatcher only maps browser/phone/launchpad, filtering unknown IDs, so effective list is Zen + phone + launchpad. Confirm ordering and whether omitted logical roles need real backends. |
| Tailscale | static match | Darwin service enabled. |
| Linux builder | superseded/unverified | Better architecture; perform detailed parity evaluation. |
| Dullahan/Gremlin/Fortress remotes | missing | Must be redesigned as capability/backends, not copied as host bundle. |

### Applications and accepted removals

Old apps included Arc, Bluesnooze, GroupMe, LaunchControl, Magnet, Signal, UTM,
Zen, and Zoom. Current application declarations add Discord and preserve most of
that set through symbolic variants, but centralized tool policy selects no Arc
and no LaunchControl. Those two removals and Discord addition are accepted.

The current application-store design has known flaws, not migration invariants:

- `appStore.tools.<tool>.enable` conflates availability with activation;
- the `applications` preset enables all tools rather than deriving activation
  from selected/resolved demand;
- Homebrew/`mas`/unfree policy can therefore enter a closure too broadly;
- selection is a closed central mapping, so a newly declared logical
  application is ignored until that mapping changes;
- variant and resolved values are weakly typed (`anything`-like contracts);
- installation policy, backend availability, backend activation, and logical
  application declaration are insufficiently separated.

Do not preserve these flaws for compatibility. Redesign after understanding
actual machine/application lanes.

### Home Manager legacy closure: required audit

This audit is not finished. The old `krad246` HM root sets username/home from
the OS user, overrides Git email to `condor-janitor0e@icloud.com`, and imports:

- complete `base-home`;
- `krad246-cachix`;
- generic Nix core;
- flake registry;
- home-link registry.

`base-home` imports Agenix, Bash, Bat, Bitwarden/RBW, Bottom, Direnv, FD, FZF,
Git, Helix, LSD, terminal fonts, packages, Ripgrep, Spotify Player, Starship,
Yazi, Zoxide, and Zsh. It also owns activation, XDG, manuals, state version, and
dotfiles behavior.

The next agent must make a row-by-row old/new ledger for at least:

- identity name/username/email and the special Git email override;
- Agenix HM module and package versus RBW capability;
- Cachix configuration;
- Nix settings and package universe;
- flake registry and home/system link registries;
- Bash behavior: vi mode, completion, VTE, Ctrl-H, reload alias, history rules,
  `tldr`, Yazi wrapper, Kitty/FZF image preview integration;
- Zsh behavior and whether its removal/nonselection is intentional;
- Bat theme, extras, aliases, BATDIFF/LESSOPEN/BATPIPE behavior;
- Bottom Linux desktop hiding;
- Direnv/nix-direnv and per-shell integrations;
- FD hidden/default options;
- old FZF widgets, bindings, preview/view/edit commands, and source semantics;
- Git identity, LFS, aliases, delta, GH credentials, Kitty integrations;
- Helix package (`evil-helix` currently), languages, settings, keymaps, and FZF
  editor integration;
- LSD colors, hyperlinking, aliases, and shell integration;
- terminal font packages and Linux fontconfig;
- package lists, including lost/added tools (`safe-rm`, `procs`, `has`, etc.);
- Ripgrep and ripgrep-all;
- Spotify Player (apparently absent in current cone);
- Starship settings and shell integration;
- Yazi settings/keymaps/integrations;
- Zoxide integrations;
- Codex moved from host-local import to development preset;
- old dotfiles sync activation and out-of-store link behavior;
- manual HTML/JSON behavior, including old Zen manual opener behavior;
- XDG configuration and Home Manager state version.

For each item classify preserved, accepted change, missing, irrelevant, or
unverified and cite exact option/config evidence. Do not infer parity from a new
file having the same tool name.

## Known closure/evaluation concerns

Use three separate measurements:

1. **source closure**: files/modules discovered or imported;
2. **evaluation closure**: inputs, package sets, and module values forced while
   evaluating;
3. **derivation/runtime closure**: store paths reachable from built results.

Primary acceptance requires disabled implementations to stay out of derivation
closures. Evaluation lightness remains part of the vision and must be improved
in prioritized passes, but it is deliberately lower priority than input-graph
discipline, derivation closure, and sound interface severability. A resident set
of backend variants plus dispatch machinery can be an acceptable vTable tax.

Examples already observed:

- Kitty imports `nixpkgs-unstable` and assigns `pkgs.unstable.kitty` even when
  its backend is disabled. Laziness may keep Kitty out of the derivation, but
  mere backend availability can enlarge evaluation scope.
- Bottom, Lazygit, and Codex similarly select unstable packages in modules that
  may be imported before enablement.
- Interface declarations should remain available without forcing backend-only
  package sets where possible.
- Importing an integration must not silently install both endpoints unless the
  profile explicitly requests both.

Create real checks/fixtures rather than relying on source inspection. A useful
matrix includes bare HM interface, minimal shell, interactive shell, dev shell,
each backend disabled/enabled, standalone HM, system-integrated HM, and backend
replacement. Inspect derivation references or closure paths for forbidden
packages.

## Acceptance gates for the `nixbook-pro` slice

All of these remain required unless the owner explicitly revises them:

- `nixbook-pro` evaluates and builds independently;
- its nested Linux-builder guest evaluates independently;
- disabled backends do not enter derivation closures;
- replacing Bash, Helix, FZF, Kitty, Zen, or an application installation tool
  does not require editing consumers;
- profile composition does not activate unrelated capabilities;
- every imported capability is used or required to expose a stable consumed
  interface;
- all functional deviations from `main` are explicit and accepted;
- Colima and `macos-container` remain intentionally excluded;
- application tools eventually activate from resolved demand, not mere
  availability;
- remote-machine definitions are rearchitected rather than silently lost;
- the slice can merge without deleting unrelated legacy hosts/closures;
- the low-level HM layer has standalone and integrated composition evidence;
- input-version differences are resolved intentionally, not hidden by lockfile
  churn.

## Bridge-to-main constraints

The bridge is not yet designed, but it is a required early milestone and the
mechanism that makes every later migration slice feasible. Derive it from
enough closure evidence to avoid baking in the wrong boundary; do not postpone
it until every parity question or high-level interface is complete. Preserve
these constraints:

- it must land on current `main`, not make `main` adopt the reconstructed
  Dendritic tree wholesale;
- legacy configurations must continue to work while individual lanes move;
- new virtual module namespaces must be introducible alongside old
  `darwinModules`, `homeModules`, and `nixosModules` exports;
- avoid requiring `ezConfigs` for new configurations;
- do not delete old modules until every consuming closure has moved;
- generated `flake.nix`/`flake.lock` changes must be isolated and explainable;
- commit boundaries should follow dependency cones and leave the flake
  evaluable;
- prefer a substrate/registry bridge followed by low-level HM lanes, profiles,
  system adapters, and host roots—not a cherry-pick of historical reconstruction
  commits whose context assumes the blanked tree;
- record old-to-new behavior decisions so future ports are closure migrations,
  not archaeology repeats.

Success means ordinary work can return to a trunk-based rhythm: introduce or
polish one capability cone, integrate it with one or more real consumers, verify
it alongside untouched legacy closures, and merge it to `main`. A bridge that
still requires carrying a broad shadow tree, periodically rebasing the entire
`dendritic` rewrite, or deleting legacy exports before their consumers move is
not a successful bridge.

A likely sequence, subject to evidence, is:

1. Dendritic virtual-module/export substrate compatible with existing outputs;
2. inputs/Nixpkgs/Home Manager foundations required by the HM cone;
3. identity and low-level shell program interfaces;
4. shell backends and explicit integrations;
5. editor/terminal capabilities and standalone HM fixtures;
6. provisional presets using `mkDefault`;
7. Darwin owner/HM adapters and narrowly needed desktop behavior;
8. remote-builder interface/backend/guest;
9. `nixbook-pro` root;
10. later remote, application, desktop, and other machine lanes.

Do not treat this likely sequence as approved implementation detail until the
audit and dependency graph establish exact commits.

## Working protocol for future agents

At the start of every continuation:

1. read this file completely;
2. inspect `git status --short --branch`, branches, worktrees, and recent logs;
3. treat current files and evaluated outputs as authoritative over historical
   statements in this handoff;
4. update stale coordinates in this file when making a durable architectural
   commit;
5. resume the closure ledger before inventing a plan from memory.

While analyzing:

- use `git show main:path` to inspect legacy sources without switching branches;
- use `rg`/`git grep` to trace imports and option assignments;
- inspect the actual old root wiring, including invisible framework injection;
- distinguish static source similarity from evaluated parity;
- record accepted changes separately from accidental omissions;
- avoid changing exploratory interfaces merely to make the audit cleaner.

Before editing:

- produce the exact transitive dependency cone for the intended slice;
- check for user changes and preserve them;
- explain whether the edit advances interface severability, backend
  replaceability, closure lightness, composability, parity, or bridgeability;
- reject changes that merely reproduce the old bundle under new names.

Before committing:

- inspect the diff and commit only the intended slice;
- run evaluation/build checks proportional to the closure changed;
- include negative closure tests for backend disablement where relevant;
- do not claim broad parity from `nix flake check --no-build` alone;
- update this handoff when a decision, status, branch coordinate, or next step
  materially changes.

## Immediate next work

1. Finish the HM program-by-program behavioral ledger listed above.
2. Evaluate the old and new `nixbook-pro` configurations where feasible and
   capture normalized option/output diffs, separating dependency-version drift
   from architectural changes.
3. Complete Linux-builder parity and independent guest evaluation.
4. Inventory remote definitions by intent so a capability interface can be
   designed later; do not copy `krad246.remotes.*` wholesale.
5. Audit the current HM module graph for implicit activation and unstable-input
   evaluation leaks.
6. Define standalone HM composition/closure tests.
7. From the minimum sufficient evidence, write the concrete coexistence bridge
   and commit graph; do not wait for exploratory app/browser/dock APIs to settle.
8. Implement the bridge on current `main` as a mandatory early deliverable and
   immediately begin landing the HM capability cone through it.

The key mental model is: this is not a file migration, a naming cleanup, or a
large rebase. It is the incremental extraction and landing of composable
capability vTables and their derived backends, proven through the real closure
of a machine.
