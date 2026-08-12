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
- The old broad per-user Nix daemon/cache policy may be omitted from the
  thinnest HM landing slice. Its absence does not block that slice.
- The Dendritic input-registry architecture is settled progress and must be
  preserved: its source/registry, filesystem sysroot projection, optional
  legacy search-path projection, and cross-context generic interface are a
  substantial improvement over the old registry plus home-link modules.
- Zsh is intentionally removed and is not required in the first HM landing.
- Preserve `condor-janitor0e@icloud.com` for Git through a local layered
  override of the owner/general identity default.
- Do not port HM Agenix in the thin HM slice. RBW remains selected.
- Remove the old mutable dotfiles synchronization/link behavior.
- Spotify Player is removed for now.
- Do not port the current terminal-font architecture. It is incoherent and
  inflates closures. Revisit fonts through a future theming capability lane and
  its relationship to Stylix.

The longer-term identity direction is a multi-identity software bus. Identity
providers publish identities through a stable virtual interface; Git queries
or selects from that bus and projects the selected identity through its own
wrapping interface. The immediate local Git email override is a deliberate
narrow bridge toward that design, not the final multi-identity API.

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
| system Agenix module and custom Agenix package | missing | Evaluated Main system packages include Agenix; Dendritic does not. `darwin.secrets` only bridges HM RBW and does not import `darwin.agenix`. Decide desired system/HM secret capabilities. |
| firewall | irrelevant | Old file contained comments only. |
| system terminal fonts | no effective difference | Although the old source assigns `fonts.packages = pkgs.krad246.term-fonts.paths`, evaluated `fonts.packages` is empty on both configurations. The actual font difference is in the HM closure, not system fonts. |
| HM bridge package universe | changed/unverified | Old had `useGlobalPkgs=true`, `useUserPackages=true`, `verbose=false`; new leaves global pkgs off, uses user packages, and is verbose. Audit package identity/overlays/unfree effects before choosing policy. |
| Homebrew substrate | changed, evaluated | Main has Homebrew disabled but declares Bash/Zsh brews, the six selected casks, and two MAS apps. Dendritic enables Homebrew, removes Bash/Zsh brews, and preserves the same six casks and two MAS apps. This activation/policy change is entangled with the exploratory app-store and requires later design; Nixpkgs Bash is accepted for thin slice. |
| guest login disabled | missing | Old master-user module set `GuestEnabled=false`; current lock-screen modules are empty. |
| console access disabled | missing | Old set `DisableConsoleAccess=true`; no current realization found. |
| screensaver password | missing | Old set `screensaver.askForPassword=true`; current screensaver module is empty. |
| custom preference dispatch | unverified | Old copied `CustomUserPreferences` to `CustomSystemPreferences`; new HM Darwin target writes domains through `targets.darwin.defaults`. Compare generated activation/defaults behavior. |
| dark mode | preserved through HM dispatcher | Evaluated HM Darwin defaults request dark, nonautomatic style. |
| Finder settings | preserved through HM dispatcher | Evaluated defaults preserve hidden/extensions, desktop, search scope, view, trash cleanup, path/status bars, POSIX title, and folders-first. |
| menu/dialog preferences | preserved through HM dispatcher | Evaluated defaults preserve expanded save/print panels, table mode, and visible menu bar. |
| pointer/trackpad | preserved through HM dispatcher | Evaluated defaults preserve flat acceleration, non-natural scrolling, right-click, corner, and scaling values. |
| keyboard basics | preserved through HM dispatcher | Evaluated HM defaults contain full keyboard access, repeat rates, text substitutions, function-key mode, window animations, and HIToolbox Fn usage. Responsibility moved from nix-darwin defaults to HM activation. |
| symbolic keyboard shortcuts | missing | Main's evaluated nix-darwin configuration contains 87 `com.apple.symbolichotkeys.AppleSymbolicHotKeys` entries. Dendritic's `desktop.input.keyboard.shortcuts` interface is empty and no equivalent mapping exists. This is a substantial unported desktop lane, not covered by the basic keyboard options. |
| Spotlight order | preserved through HM dispatcher | Evaluated HM defaults contain the same explicit ordered list. |
| window manager/spaces | preserved through HM dispatcher | Evaluated domains preserve the legacy WindowManager values and `spans-displays=false`. |
| Dock constants | preserved through HM dispatcher | Evaluated HM defaults preserve old autohide, magnification, tile size, corners, recents, and related values. |
| Dock apps | behavior preserved, interface partial | Effective Dendritic list is Zen, iPhone Mirroring, Launchpad, matching Main's host-prepended Zen plus two base pins and intended order. Defaults also request file-manager, terminal, and editor IDs, but the dispatcher silently filters them because no path providers exist. Current behavior matches while the logical dock contract remains incomplete. |
| Tailscale | static match | Darwin service enabled. |
| Linux builder | architecturally superseded; two regressions | Final embedded guest evaluation proves both preserve aarch64 host platform, 8 cores, 16 GiB RAM, 64 GiB disk, ccache, swapspace, zram, 16 GiB `/swapfile`, `TERM=xterm-256color`, Bottom, and disabled coredumps. Dendritic drops i686 from advertised/emulated systems. It also imports `environment.enableAllTerminfo`, pulling many terminal-emulator packages into the guest runtime closure; remove or replace this broad realization. Nix policy differs with branch era and should be classified separately. |
| Dullahan/Gremlin/Fortress remotes | missing | Must be redesigned as capability/backends, not copied as host bundle. |

Evaluated system package placement also confirms expected accepted removals:
Main includes Colima, the macOS container package, and Docker; Dendritic does
not. Main includes system Agenix and Lorri; Dendritic does not. Dendritic adds
Discord as a system Nix package. `m-cli` moves from Main's system package set to
the Dendritic owner HM package set. Both retain Tailscale and the normal
nix-darwin packages. The login shell changes from `/opt/homebrew/bin/bash` to
Nixpkgs Bash as explicitly accepted.

The three legacy remote modules are imported into the old logical source and
option closure but all are disabled for `nixbook-pro`, so they contribute no
effective builder/SSH configuration or derivation closure today. Their intent
contains at least three separable concerns: named SSH endpoints, proxy-jump
routes to nested builders (`headless-penguin`/`smeagol`), and Nix distributed
build-machine scheduling. Future design should not assume one module per named
host is the correct capability boundary.

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

### Home Manager legacy closure: evaluated audit in progress

The old `krad246` HM root sets username/home from the OS user, overrides Git
email to `condor-janitor0e@icloud.com`, and imports:

- complete `base-home`;
- `krad246-cachix`;
- generic Nix core;
- flake registry;
- home-link registry.

`base-home` imports Agenix, Bash, Bat, Bitwarden/RBW, Bottom, Direnv, FD, FZF,
Git, Helix, LSD, terminal fonts, packages, Ripgrep, Spotify Player, Starship,
Yazi, Zoxide, and Zsh. It also owns activation, XDG, manuals, state version, and
dotfiles behavior.

Both configurations have now been evaluated directly using current
`dendritic` and `git+file://...?ref=main`; the following is effective-output
evidence rather than filename inference.

| HM responsibility | Status | Evaluated/source evidence and follow-up |
|---|---|---|
| username/home directory | preserved | Both evaluate to `krad246` and `/Users/krad246`. |
| identity name | preserved | Both Git configurations use `Keerthi Radhakrishnan`; Dendritic derives it from `identity.person`. |
| special Git email | required local override | Preserve `condor-janitor0e@icloud.com` with a local layered Git override. Longer term select it from the multi-identity software bus rather than changing the general person default. |
| RBW | preserved with better interface | Enabled in both. Dendritic derives email from `identity.person` and selects platform pinentry behind `identity.secrets.backends.rbw`. |
| HM Agenix module/package | accepted removal | Do not port it in the thin HM slice. RBW remains selected. |
| Cachix binary-cache policy | accepted omission for thin slice | Main user Nix settings include krad246 Cachix; Dendritic user Nix settings do not. Old broad daemon/cache policy need not block first HM landing. |
| broad per-user Nix policy | accepted omission for thin slice | Main evaluates many performance, sandbox, retention, timeout, and cache settings; Dendritic HM evaluates only `experimental-features = [nix-command flakes]` through the registry. |
| input flake registry | architecturally superseded/win | Both expose registries. Dendritic replaces old `flake-registry` with the generic configurable input-registry source and locked/unlocked behavior. Preserve Dendritic design. |
| registry filesystem projection | changed, capability available | Main installs `~/nix/path/*` links unconditionally via `home-link-registry`. Dendritic has a general `input-registry.sysroot.install` projection and optional search-path projection, currently disabled for this consumer. Selection policy remains to decide; architecture is settled. |
| dotfiles link/sync | accepted removal | Do not port the mutable synchronization/link behavior. |
| XDG | changed | Main evaluates `xdg.enable=true`; Dendritic evaluates false, while both prefer XDG directories. Likely foundation parity item. |
| manuals | changed | Effective Main: HTML false (Zen override), JSON true. Dendritic: HTML false, JSON false. Decide general HM manual policy independently of browser integration. |
| state version | version drift | Main evaluates 26.05 and Dendritic 25.11 due branch input eras. Resolve intentionally during port; do not copy one blindly. |
| Lorri | preserved on Darwin | Disabled in both on this host. Dendritic dev preset enables it only on Linux. |
| Bash selection | preserved | Bash enabled in both with completion, VTE, and vi mode. |
| Bash history | changed | Main ignores `exit` and `reload`; Dendritic ignores only `exit`. Control values are semantically the same, reordered. |
| Bash Ctrl-H binding | missing | Main explicitly unbinds Ctrl-H; Dendritic does not. |
| Bash reload alias | missing | Main reconstructs Bash RC and reloads Direnv; Dendritic does not define it. |
| Bash `tldr` alias | changed | Main defines executable-resolved alias; Dendritic installs `tldr` but does not define that alias. Likely harmless, verify desired UX. |
| Bash-Yazi wrapper | preserved | Both provide `y()` with cwd-file behavior; Dendritic gates it through explicit integration. |
| Bash integrations | architecturally improved, parity incomplete | Dendritic explicitly dispatches Direnv, FZF, LSD, Kitty, Starship, Yazi, and Zoxide. Old Kitty+FZF image-preview environment behavior is not visibly reproduced. |
| Zsh | accepted removal | Do not port or select Zsh for the first HM landing. |
| Bat theme | preserved | Gruvbox dark in both; Dendritic also sets terminal title. |
| Bat extras | changed | Main includes batdiff, batgrep, batman, batpipe, batwatch, prettybat. Dendritic effective closure includes batdiff, batgrep, batman, prettybat but not batpipe/batwatch as packages. Batpipe is invoked conditionally through a Bash integration and needs closure validation. |
| Bat aliases/environment | changed | Main aliases `cat` to `bat -pp`, resolves `brg`/`man`/`bdiff` to store executables, and sets BATDIFF/LESSOPEN/LESS/BATPIPE. Dendritic aliases `bat` to `prettybat`, keeps `brg`/`man`/`bdiff` by command name, sets BATDIFF, and delegates LESS/PAGER to its pager capability. It drops the old `cat` alias and batpipe `LESSOPEN`/`BATPIPE` environment. Decide desired composition rather than blindly restore. |
| Bottom | preserved enablement, changed config | Enabled in both; Dendritic adds substantial settings and selects unstable. Old Linux no-display desktop entry is commented out in Dendritic and matters only to the standalone Linux consumer. |
| Direnv/nix-direnv | preserved | Enabled in both; Dendritic makes shell integrations explicit. |
| FD | preserved enablement, changed option | Both enabled. Main sets `hidden=false`; Dendritic adds `--hyperlink auto`. Confirm candidate semantics rather than option spelling. |
| FZF | architecturally improved, effective config changed | Enabled in both. Dendritic factors picker sources/actions/bindings and FD/Bat/Helix integrations. Normalized output preserves Ctrl-T/Alt-C/Ctrl-R, preview, reload, multi-view, and edit behaviors. New reload commands correctly use the relevant logical source (directories reload `fd --type d`) instead of Main's shared/eval-wrapped default command. Option ordering/store versions differ. Full `programs.fzf` attrset cannot be serialized on either branch because HM exposes the removed `historyWidgetCommand` option; compare selected supported fields and generated shell environment instead. |
| Git base settings/LFS/aliases | mostly preserved | Core settings, LFS, aliases, merge/push/rebase policy are present. Effective hash differs due email and credential integrations. |
| Git credentials | regression/decision required | Main enables `git-credential-oauth` and GH helpers for GitHub/Gist. Dendritic evaluated Git credential map is empty because new GH identity slots default to null. Design identity slots and secret/token flow before claiming parity. |
| Delta/Lazygit | mostly preserved, version-sensitive schema | Same core Delta flags and Lazygit preferences/keybindings are split into capabilities. Main 26.05 effective config uses `git.diffRenderer[].command`; Dendritic 25.11 uses `git.pagers[].pager`. Preserve the capability relationship but adapt its realization to the target HM/Lazygit schema during port. |
| Helix package/default | preserved | Both enable `evil-helix` as default editor. |
| Helix settings/keymaps | two known changes | Dendritic removes `Alt-] = nix fmt` in all modes and changes `Alt-F` from no-op to `format_selections` in normal/select. Everything else in normalized effective settings matches. Confirm changes. |
| Helix languages | regression plus deliberate additions | Dendritic adds Nix/nixd but drops Rust, docker-compose, Bash shfmt, rust-analyzer, and systemd server declaration. More seriously, evaluated output nests language entries under `languages.language` instead of top-level `language`, suggesting an erroneous extra `languages` level in the module. Fix before HM landing. |
| FZF-Helix edit action | structurally preserved | Both build a no-suspend Helix wrapper; Dendritic exposes it through picker action vTable. Test produced command. |
| LSD | preserved exactly | Normalized effective configuration hashes match. |
| terminal fonts | accepted architectural removal/deferral | Do not port the old font bundle. It is incoherent and bloats closures. Kitty's direct font realization may remain only as backend-local behavior pending a future theme/Stylix capability design. |
| Kitty terminal | preserved plus explicit integration | Enabled in both. Normalized effective settings, keybindings, theme, font, launch options, and shell-integration values match modulo store path. Dendritic additionally enables HM's Git integration through an explicit Git-Kitty capability relationship; Main leaves it false. |
| base package set | changed | Main-only notable tools include `safe-rm`, `procs`, `has`; Dendritic adds a larger dev/interactive set including curl, file, jq, tree, archives, CMake/GDB/binutils, and Nix diagnostics. Classify by preset lane rather than demand exact set equality. |
| Ripgrep + ripgrep-all | preserved | Both enabled. Dendritic integration split provides Bat behavior. |
| Spotify Player | accepted removal | Drop it for now. |
| Starship | preserved exactly | Normalized settings hashes match; Dendritic shell integration is explicit. |
| Yazi keymap | preserved exactly | Normalized keymap hashes match. |
| Yazi settings | preserved modulo HM defaults | Normalized diff shows Dendritic adds only empty `opener`, `plugin`, and `which` sets; authored manager/input/preview behavior is otherwise equal. Keymap is exactly equal. |
| Zoxide | preserved | Enabled in both; Dendritic shell integration is explicit. |
| Codex | preserved, better placement | Enabled in both. Dendritic moves it from a host-local HM import into the development preset. |
| Zen profile customization/manual opener | missing/changed | Main HM closure contains managed Zen/Firefox profile files and browser-specific manual behavior. Dendritic browser backend currently supplies default opener/app path but not profile management. High-level browser interface remains exploratory. |

The effective shell environment also reveals that Main's `xdg.enable=true`
exports `XDG_BIN_HOME`, `XDG_CACHE_HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME`,
and `XDG_STATE_HOME`, while Dendritic currently exports none of them. Dendritic
adds `BROWSER`, `PAGER`, `LESS`, and BATDIFF through explicit capabilities.
Both export editor and FZF/Starship values. Main additionally exports a TERMINFO
path. Treat XDG and TERMINFO as concrete foundation/terminal parity work.

Still complete Git/GH identity behavior, exact generated Bash/FZF integration
scripts, terminal/Kitty behavior, and generated file/activation effects. Then
classify every decision-required row with the owner before fixing or porting it.
Do not turn old behavior into a requirement automatically.

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

### Contractor relationship and questioning style

Treat the repository owner as the boss/product owner and the active agent as a
senior implementation contractor. The owner sets requirements, priorities,
architectural intent, and which behavioral differences are accepted. The agent
is responsible for investigation, technical judgment, implementation quality,
verification, and maintaining the durable context system.

Do not silently fill genuine requirement ambiguity with a convenient technical
choice. Ask questions whenever different plausible answers would change:

- a capability boundary or public virtual namespace;
- whether behavior is preserved, removed, or redesigned;
- which backend or preset is selected;
- the scope/order of a landing slice;
- a compatibility or coexistence promise;
- an invariant, acceptance gate, or meaning of completion;
- a destructive or difficult-to-reverse migration step.

Ask as many questions as needed to remove those ambiguities. Questions are not
a substitute for engineering work: first inspect the repository, evaluate the
relevant closures, and narrow uncertainty. Present each question with:

1. the concrete evidence that created it;
2. the exact decision being requested;
3. the viable alternatives;
4. consequences for behavior, closure, architecture, and landing order;
5. the agent's recommendation and why;
6. whether work can continue independently while awaiting the answer.

Do not ask the owner to rediscover facts available in the tree. Do not bury a
material choice in a long report or phrase it as a fait accompli. Conversely,
do not stop for inconsequential implementation details that are reversible and
fully determined by recorded invariants.

When the owner corrects an interpretation, treat the correction as new
authoritative requirements input. Reflect it back precisely, run the mandatory
decision-sync protocol, then revisit any analysis or plan whose conclusions
depended on the old interpretation.

The desired feedback loop is:

```text
owner requirement or correction
          ↓
agent gathers/updates authoritative evidence
          ↓
agent states invariants, options, consequences, and recommendation
          ↓
owner decides unresolved requirement questions
          ↓
agent synchronizes the committed context bundle
          ↓
agent implements and verifies against explicit proof obligations
          ↓
agent reports evidence, remaining questions, and next selectable lanes
          ↺
```

### Reasoning about invariants

Before designing or changing a capability, extract its invariants in plain
language. An invariant is not a preference or a module name; it is a property
that must remain true across implementations and compositions. For each one,
record:

- scope: which interface, backend, integration, preset, or consumer it governs;
- rationale: what architectural/user requirement it protects;
- positive examples and counterexamples;
- proof obligation: the evaluation, build, closure inspection, or replacement
  test that demonstrates it;
- override policy: whether a preset/host may weaken it, and how explicitly;
- status: proposed, owner-confirmed, implemented, or verified.

Reason from invariants toward module boundaries, not from existing files toward
post-hoc justifications. Test proposed interfaces with at least these questions:

- Can a consumer express intent without naming a backend?
- Can a second backend satisfy the contract without changing the consumer?
- Can either endpoint of an integration exist without the other?
- Does importing the interface install or force an implementation?
- Can presets select defaults without preventing caller overrides?
- Can both immediate consumers—integrated and standalone HM where relevant—use
  the same contract?
- What exact output would falsify the claimed closure property?

If a discovered counterexample invalidates an invariant or shows it was stated
too broadly, stop treating it as established. Surface the conflict to the owner
when it affects requirements, refine it, synchronize the bundle, and update its
proof obligations.

### Proof-carrying architecture and validation budget

The purpose of a sound architecture is partly to make downstream work obvious
and cheap. Once an invariant is established at the correct boundary, treat it
as a reusable proof premise. Do not repeatedly relitigate that premise at every
consumer, call site, or port.

Canonical example: a family of Nix repositories consumes a platform repository
through a base-derived package set and ordered overlay composition. If the
platform contract guarantees that a symbol is present in the base or a shared
overlay, and overlays in the supported chain extend/override without deleting
that symbol, then the symbol is valid for downstream `callPackage` scopes. Do
not repeatedly search every consumer to ask whether it exists. The composition
relationship is the proof.

Apply the same reasoning to Dendritic module work:

- a consumer importing a declared virtual interface may rely on that interface;
- a preset importing a backend may rely on its declared options;
- a generic module proven applicable to HM and system contexts need not be
  re-proven at every consumer;
- an input guaranteed by the substrate/follows graph need not be rediscovered
  at every module;
- a backend replacement test established for an interface should become a
  reusable gate rather than a repeated design debate.

Validation effort belongs at boundaries and invalidation events. Revalidate an
established premise only when one of these occurs:

- base/package-set/platform source changes in a way relevant to the contract;
- overlay ordering or composition changes;
- an overlay replaces a containing attribute set non-monotonically, uses
  `removeAttrs`, or otherwise may remove the guaranteed symbol;
- a consumer stops using the supported platform-derived path;
- module import/applicability rules change;
- an input follow/deduplication relationship changes;
- direct evaluation/build evidence contradicts the invariant;
- the owner explicitly asks to reopen the invariant.

Absent an invalidator, land straightforward code using the proven premise. Do
not spend context, commands, or owner attention validating facts the
architecture already guarantees. This is not permission to skip acceptance
tests for new boundaries or behavior; it is a rule against duplicating proof
after the relevant boundary has already supplied it.

When defining an invariant, record its invalidators along with its proof
obligation. This lets future agents cheaply decide whether existing evidence is
still applicable. Prefer one strong substrate/interface test over many weak
consumer-level existence checks.

The target steady state is intentionally low-friction: most routine ports
should follow recorded invariants mechanically, consume little context, require
no architectural re-debate, and land correctly with only checks at genuinely
changed boundaries.

### Evolving the context root filesystem

Treat `.agents/dendritic/` as a content-addressed context root filesystem. It is
intended to contain enough authoritative state, routing, procedures, and
evidence that an unfamiliar successor can execute it like a program and recover
the project's working model without keeping the entire history in memory.

As the owner teaches a new collaboration preference, reasoning method,
architectural rule, vocabulary term, or review expectation:

1. determine whether it is durable/general or only local to the current task;
2. for durable guidance, identify its canonical section or add a narrowly named
   section and lazy route;
3. connect it to the decision-sync protocol and any affected working steps;
4. add executable checks or proof templates when prose can be mechanized;
5. remove or rewrite superseded guidance so the rootfs is internally coherent;
6. refresh, verify, and commit the new proxy hash;
7. exercise the route from a cold-reader perspective: it must say what to read,
   what to do, what evidence to collect, when to ask, and how to persist the
   result.

Do not optimize the canonical rootfs for minimum byte count at the expense of
losslessness. Optimize the always-loaded proxy and route selection for low
static context cost; expand canonical detail dynamically. The hash is an
integrity/version proxy, not a magical semantic compression: a new agent must
read the routed source to recover meaning.

### Mandatory architectural decision synchronization

Conversation is not the durable source of truth. Whenever the owner makes a
decision that changes architectural direction, scope, priority, accepted
behavior, terminology, a migration gate, or the status of an interface, the
active agent must synchronize that decision into this playback bundle.

This applies to explicit decisions and to corrections such as:

- accepting or rejecting a parity difference;
- declaring an interface settled, exploratory, superseded, or intentionally
  omitted;
- changing which lane lands first;
- changing the relationship between bridge work and feature-branch work;
- establishing a new invariant, exception, priority ordering, or closure rule;
- correcting the old/new closure graph or branch mechanics;
- answering an open question in a way that changes future implementation.

Use this protocol immediately after the decision, before continuing work whose
interpretation depends on it:

1. restate the decision and its consequence to the owner, checking that the
   interpretation is unambiguous;
2. locate every affected statement, ledger row, acceptance gate, next step, and
   route in `.agents/dendritic/context.md` and `routes.tsv`;
3. update those locations consistently—do not merely append a contradictory
   note while leaving stale instructions elsewhere;
4. preserve relevant historical evidence and label the new status/decision;
   distinguish a changed owner decision from a newly discovered fact;
5. run `.agents/dendritic/context.sh refresh` to regenerate the manifest and
   root `AGENTS.md` proxy hash;
6. run `.agents/dendritic/context.sh verify`, route-expansion checks, shellcheck,
   and `git diff --check`;
7. inspect the canonical and generated diffs for accidental loss;
8. commit the bundle update with the implementation that embodies the decision,
   or make an immediate context-only commit when implementation will follow in
   later work;
9. report the commit and new proxy hash. Do not claim persistence before the
   commit exists.

If a later discovery contradicts a recorded decision, do not silently rewrite
history or implement around it. Surface the contradiction, obtain direction if
the resolution is not already implied, and then run this protocol again.

The active long-running goal, conversation transcript, local caches, plans, and
model memory are useful indexes but are not substitutes for this committed
bundle. A future model must be able to reconstruct the current architecture and
why it changed using repository state alone.

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
