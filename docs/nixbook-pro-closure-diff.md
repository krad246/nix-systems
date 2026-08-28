# `nixbook-pro` closure diff: legacy -> dendritic

Date: 2026-08-12

Compared revisions:

- Legacy/current: `general-longstanding-cleanup` at `6e2ecfb4`
- Target: `dendritic` at `5940c9bf`

## Purpose

This is a behavioral and composition-closure audit, not a request to restore the
old tree file-for-file. The first target is a buildable
`dendritic#darwinConfigurations.nixbook-pro.system`. When legacy behavior is
absent, intentionally deleted, or in conflict with the dendritic interfaces, it
is recorded as a task or decision rather than silently copied.

There are three different closures to keep distinct:

1. **Module source/evaluation closure**: modules that must be loaded and merged.
2. **Flake input closure**: inputs that must be locked, fetched, and evaluated.
3. **Runtime/store closure**: packages and services reachable from the resulting
   system derivation.

The old architecture inflates all three in places. The dendritic tree uses
merged module namespaces as deliberate virtual interface boundaries. A merged
namespace is not, by itself, evidence of a failure to sever the realized or
store closure: its contributors may need a common option graph while conditional
configuration keeps inactive realizations out of the result.

## Evaluation status

The legacy target evaluates successfully:

```console
$ nix eval --raw .#darwinConfigurations.nixbook-pro.system.drvPath
/nix/store/32qiyff70r8bk4vhzq5qyalyi1piyxfm-darwin-system-26.05.c3e90c8.drv
```

The equivalent evaluation of an archive of `dendritic` also succeeds when run
with access to the Nix daemon:

```console
$ nix eval --offline --raw /tmp/dendritic-closure-audit#darwinConfigurations.nixbook-pro.system.drvPath
/nix/store/ig0nlbmwsb6b8ih7irxa4a5fcdfcakhk-darwin-system-25.11.ebec37a.drv
```

An earlier attempt from the restricted execution environment failed to access
the Nix daemon. That sandbox failure was initially misclassified as target
evaluation behavior; it is not a defect or performance finding against the
dendritic configuration.

### Derivation-requisite comparison

The two derivation graphs were queried with `nix-store --query --requisites`:

| Measure | Legacy (26.05) | Dendritic (25.11) |
|---|---:|---:|
| Total requisite store paths | 16,957 | 13,925 |
| Derivations | 15,871 | 12,976 |
| Non-derivation paths | 1,086 | 949 |
| Unique basenames after removing store hashes | 7,640 | 7,012 |
| Exact shared basenames | 4,906 | 4,906 |

The dendritic derivation graph has 3,032 fewer requisite paths (about 18%), but
this is **not an architectural efficiency score**. The roots use different
nixpkgs generations, package versions, bootstrap chains, Darwin SDK/toolchains,
Nix versions, and Linux-builder/NixOS dependency graphs. Exact store-path or
versioned-basename subtraction therefore mostly measures channel skew.

Neither system output is realized locally, so a runtime closure size comparison
cannot yet be obtained with `nix path-info -Shr`. The reliable comparison below
uses evaluated package lists and effective option values, with versions ignored
unless the version itself changes behavior.

## Legacy evaluated root

`ez-configs` assembles the host and attaches the `krad246` Home Manager user.
The effective project-owned import shape is:

```text
darwinConfigurations.nixbook-pro
├── configurations/darwin/nixbook-pro/default.nix
│   ├── configuration.nix
│   │   ├── darwinModules.apps
│   │   ├── darwinModules.base-configuration
│   │   ├── darwinModules.colima
│   │   ├── darwinModules.macos-container
│   │   └── darwinModules.tailscale
│   └── remotes.nix
│       ├── generic.dullahan
│       ├── generic.gremlin
│       └── generic.fortress
└── configurations/home/krad246.nix
    ├── homeModules.base-home
    ├── generic.krad246-cachix
    ├── generic.nix-core
    ├── generic.flake-registry
    ├── generic.home-link-registry
    └── Darwin HM specialization
        ├── mac-app-util
        ├── discord
        ├── kitty
        └── zen
```

The two largest amplification points are:

- `base-configuration/default.nix` imports nearly every Darwin policy plus six
  generic modules, whether or not a host needs each concern.
- `base-home/default.nix` imports the entire interactive/development package and
  program suite. The Darwin specialization then adds desktop applications.

The three remote modules are imported even though every remote is disabled for
`nixbook-pro`. They enlarge the module evaluation closure without contributing a
build machine. Only the local `linux-builder` is active.

### Evaluated legacy package surface

The current derivation was queried, rather than inferring this list only from
source.

System-level notable packages:

```text
m-cli, mas, agenix, container, colima, docker, bash, tailscale, lorri, nix
```

Home-level notable packages/programs:

```text
coreutils, safe-rm, tldr, sd, duf, dust, procps, procs, undollar, has,
gnumake, just, agenix, discord, cachix, mas, m-cli, zsh, zoxide, yazi,
starship, spotify-player, ripgrep, ripgrep-all, rbw, lsd, lazygit, kitty,
Meslo Nerd Font, evil-helix, git, git-lfs, git-credential-oauth, gh, fzf,
fd, direnv, delta, codex, bottom, bat and bat-extras, bash
```

Application-store surface:

```text
Homebrew casks: zoom, zen, crystalfetch, utm, signal, bluesnooze
Mac App Store: Magnet, Unite/GroupMe
Nix package: discord
```

The local Linux builder advertises `i686-linux`, `x86_64-linux`, and
`aarch64-linux`, with `maxJobs = 60`.

### Version-normalized effective package diff

Ignoring ordinary package-version changes caused by the 26.05/25.11 nixpkgs
skew, the evaluated top-level package selections differ as follows.

Absent from the dendritic system selection (not presumed to be regressions):

```text
agenix, container, colima, docker, lorri, m-cli
```

New or moved into the dendritic system selection:

```text
brew, discord
```

`discord` is not a functional addition: it moves from the legacy HM package set
to the Darwin application-store Nix backend. `m-cli` moves in the other
direction, from the system package set into the HM interactive shell policy.

Absent from the dendritic HM package selection (including intentional drops and
redundancies):

```text
safe-rm, procs, has, agenix, spotify-player, git-credential-oauth,
HM-managed zsh
```

`mas` and `discord` also disappear from HM because they move to system-level
application-store ownership. Some generated documentation packages differ
between Home Manager versions and are not treated as capability changes.

New in the dendritic HM package selection:

```text
curl, file, gnutar, jq, tree, which, unzip, zip,
binutils, cmake, gdb, nix-diff, nix-du, nix-fast-build,
nix-output-monitor, man-db, less
```

The first line changes the interactive/base CLI policy. The second and third
lines expand the dev and manual/pager policies. Existing tools such as Bash,
Codex, Git, Helix, Kitty, RBW, ripgrep, fzf, Yazi, Starship, bat, bottom, and the
Meslo Nerd Font remain present despite their version changes.

### Standardization policy encoded by dendritic

The dendritic result expresses a preferred-tool stack rather than a
file-for-file migration:

| Interface | Standard selection |
|---|---|
| Interactive shell | Nix Bash |
| Editor | Helix (`evil-helix` realization) |
| Terminal | Kitty |
| Browser | Zen |
| Picker | fzf |
| Diff renderer | delta |
| Pager/content rendering | less + bat/bat-extras integrations |
| File listing/navigation | lsd, Yazi, zoxide |
| Prompt | Starship |
| Git workflow | Git + gh + lazygit |
| Secret retrieval | RBW |
| Darwin cask installation | Homebrew casks |
| App Store installation | MAS |
| Nix-packaged Darwin application | Discord |

Several apparent removals line up with those choices:

- Brew Bash/Zsh and HM Zsh give way to one Nix Bash selection.
- `procs` disappears while `procps` remains.
- `safe-rm` is explicitly commented rather than silently lost.
- `git-credential-oauth` disappears while the Git/gh integration is enabled.
- `mas`, `m-cli`, and Discord move to the layer that owns their capability
  rather than being duplicated in HM and system package lists.

These are evidence of consolidation. They should not become parity-restoration
tasks unless the resulting behavior is actually missing. `has` and
`spotify-player` do not have equally clear replacements in the evaluated result,
so their disposition remains documentary rather than an assumed defect.

### Effective application-store diff

After evaluating the configurations, both describe the same six casks and two
Mac App Store applications:

```text
Casks: bluesnooze, crystalfetch, signal, utm, zen, zoom
MAS: Magnet, Unite/GroupMe
Nix: Discord
```

The important difference is activation, not membership:

- Legacy: `homebrew.enable = false`; the declarations are latent.
- Dendritic: `homebrew.enable = true`; Brew installation, update, upgrade, and
  `zap` cleanup behavior is active.

The dendritic result also removes the two declared Brew formulae, Bash and Zsh,
and selects Nix's Bash as the user's login shell instead of
`/opt/homebrew/bin/bash`.

### Effective Nix-policy diff

Both retain the host-specific values `auto-allocate-uids = false`,
`auto-optimise-store = false`, `extra-sandbox-paths = [ "/nix/store" ]`,
`keep-derivations = true`, and `max-substitution-jobs = 60`.

Dendritic adds these experimental features:

```text
ca-derivations, dynamic-derivations, recursive-nix
```

It no longer carries these legacy policy values:

```text
connect-timeout = 300
fsync-metadata = true
keep-build-log = true
keep-env-derivations = true
keep-going = true
keep-outputs = true
max-silent-time = 3600
min-free = 16G
preallocate-contents = true
sync-before-registering = true
timeout = 3600
trusted-substituters = [ cache.nixos.org nix-community.cachix.org ]
```

Most importantly, the evaluated sandbox policy changes from
`sandbox = true; sandbox-fallback = true` to both values being `false`. This is
a real behavioral delta, not package-version noise, and deserves an explicit
decision before switching the host.

## Dendritic reachable root

The target root is explicit:

```text
modules/hosts/nixbook-pro/configuration.nix
├── darwin.workstation
│   ├── darwin.applications
│   │   ├── every declared application backend
│   │   └── app-store selection policy
│   ├── darwin.base
│   │   ├── home-manager
│   │   ├── input-registry
│   │   ├── nix
│   │   ├── nixpkgs-instance
│   │   ├── owner
│   │   └── HM user -> homeManager.base
│   ├── darwin.desktop
│   │   ├── app-stores and all three installation tools
│   │   ├── Darwin browser realization
│   │   └── HM user -> homeManager.desktop
│   ├── darwin.dev -> HM user -> homeManager.dev
│   └── darwin.secrets -> HM user -> homeManager.secrets
├── darwin.linux-builder -> darwin.remote-builder
└── darwin.tailscale
```

The Home Manager side expands to:

```text
homeManager.base
├── identity
├── input-registry
└── shell
    ├── all interactive tool modules
    ├── Bash backend
    └── Nushell backend

homeManager.desktop
├── browser -> Zen backend
├── terminal -> Kitty backend
└── every contributor merged into the shared `desktop` module attribute

homeManager.dev
├── editor -> Helix backend
└── shell dev profile -> Codex, direnv, gh, git, lazygit, lorri
```

## Topology and severability interpretation

### 1. Shared aggregate attributes are virtual interface boundaries

Many files contribute to the same attribute, notably:

```text
self.modules.homeManager.shell
self.modules.homeManager.desktop
self.modules.homeManager.helix
self.modules.homeManager.kitty
```

These are intentionally merged namespaces. The contributors jointly establish
the option graph needed by cross-cutting integrations and backend dispatch. For
example, `homeManager.shell` is the virtual shell interface even though its
definition is distributed across interface, program, integration, policy, and
backend files.

The relevant audit question is therefore not whether a selected namespace loads
all of its definitions. It is whether inactive branches contribute packages,
services, activation code, or other realized configuration after module
evaluation. File-level or definition-level isolation is not a requirement of
this topology.

### 2. `workstation` is a policy boundary

`darwin.workstation` unconditionally imports applications, base, desktop, dev,
and secrets. This may be the intended meaning of the profile rather than closure
leakage. The closure test is whether `nixbook-pro` is meant to select the whole
workstation policy and whether optional realizations within it disappear when
disabled. If a smaller host policy is needed, it should be expressed as another
profile or composition, not by mechanically splitting the merged namespaces.

### 3. Application selection is a virtual registry and dispatcher

`darwin.applications` imports all application modules and enables all three
installation tools. The `appStore.install` function selects the realization,
while application modules contribute variants to a common registry. As with the
shell interface, the presence of definitions in the module evaluation is not a
runtime-closure defect. The check needed here is that unselected variants and
installer backends do not contribute packages or activation behavior.

### 4. Shell backend substitution uses conditional realization

The option model supports Bash versus Nushell, but both backend files contribute
to the virtual `homeManager.shell` interface. This is intentional: structural
dependencies and integrations require a shared option topology. Severability is
provided by conditional realization, so the concrete test is that disabling
Nushell removes Nushell's package and configuration while leaving the shared
interface intact.

### 5. Global flake inputs limit input-level severability

The generated root flake declares the full input set. Capability modules guard
some imports with `inputs ? ...`, but a consumer of the monolithic flake still
inherits its locked input graph. True input side-loading/repointing needs either
consumer-supplied module arguments/input adapters or smaller flakes whose inputs
are composed above the capability boundary.

## Behavior and package gap ledger

Status meanings:

- **Present**: represented in the dendritic reachable path.
- **Changed**: represented through a materially different interface or policy.
- **Task**: missing or not proven; decide/port explicitly.
- **Intentional deletion candidate**: source indicates deliberate removal, but
  keep it visible until accepted.

| Concern | Legacy behavior | Dendritic state | Status / task |
|---|---|---|---|
| Host identity | `krad246`, UID 501/GID 20, Darwin home | `owner` plus host UID/GID override | Present |
| Host platform | `aarch64-darwin` via `nixpkgs.system` | `nixpkgs.hostPlatform` | Present, modernized |
| Local Linux builder | 8 cores, 16 GiB, ephemeral, 60 jobs, 16 GiB swap; advertises i686/x86_64/aarch64 Linux | Same primary values via `remoteBuilder`; advertises x86_64/aarch64 Linux | Present; decide whether dropping i686 is intended or channel-derived |
| External remotes | Three disabled remote definitions | No host imports | Intentional closure reduction; retain as optional provisioning capability only if wanted |
| Tailscale | Enabled with tests disabled on overridden package | Enabled, stock package | Changed; decide whether the old `doCheck = false` override remains necessary |
| Colima/Docker | Enabled with launchd agent and shared builder sizing | No corresponding reachable module | Task: port as optional virtualization capability or explicitly retire |
| macOS `container` | `pkgs.unstable.container` installed | No corresponding reachable module | Task or intentional deletion |
| Agenix | Darwin and HM modules imported; package present | Modules exist but `workstation/secrets` selects RBW only | Task: decide system-secret backend and import only when selected |
| RBW | Enabled in HM | Enabled by `homeManager.secrets` | Present |
| Nix registry/search path | System and home link registries | New `input-registry` interface | Changed; verify equivalent registry and `NIX_PATH` results |
| Nix policy | Large durability/performance policy with sandbox enabled | Smaller policy, new CA/dynamic/recursive features, sandbox disabled | Task: decide the explicit effective-value diff above, especially sandboxing |
| Darwin Nix daemon | `NIX_REMOTE`, UID allocation and sandbox path overrides | Host carries these overrides | Present |
| Homebrew shell packages | Brew Bash and Zsh declared; owner shell points at Brew Bash | No Brew shells; Nix Bash selected as user shell | Conflict: intentional provenance change; verify migration of the existing login shell |
| Homebrew lifecycle | Effective `homebrew.enable = false`; casks/MAS entries are latent | Effective `homebrew.enable = true`; casks/MAS entries are active | Material behavior change: dendritic will actually run Brew activation with cleanup/upgrade |
| Darwin preferences | Large nix-darwin defaults bundle | Mostly translated into HM `targets.darwin.defaults` interface | Changed; verify applied user/domain semantics, not just equal values |
| Keyboard symbolic shortcuts | Large `CustomUserPreferences` map | Empty `desktop.input.keyboard.shortcuts` interface | Task: port behind Darwin backend or explicitly discard |
| Dock | Defaults plus phone mirroring, Launchpad, Zen | Interface maps pinned IDs and default browser | Present conceptually; evaluate final plist values |
| Finder/Spotlight/window/pointer | Direct nix-darwin defaults | HM Darwin desktop dispatcher | Present conceptually; parity test required |
| Automatic macOS updates | Enabled | Host enables directly | Present |
| Touch ID sudo | Enabled | Host enables directly | Present |
| mac-app-util | HM module imported | Input/module absent | Task: determine whether Nix-installed GUI apps require app linking; app-store Nix packages alone may not expose `.app` bundles correctly |
| Applications | Zoom, Zen, crystalfetch, UTM, Signal, Bluesnooze, Magnet, GroupMe, Discord | Exact application set is present; Discord moves from HM to Darwin system packages | Present; verify Nix-installed Discord `.app` exposure |
| Arc/LaunchControl | Imported but disabled on host | Mappings resolve to `null` | Present as non-selected capabilities; exports should be severable |
| Base CLI packages | Includes `safe-rm`, `has`, `procs`, and `procps` | Retains `procps`; `safe-rm` is commented; `has` and `procs` absent | Consolidation is evident for `procs`; document `has` disposition |
| General CLI additions | Smaller old set | Adds `curl`, `file`, `gnutar`, `jq`, `tree`, `which`, `unzip`, `zip` | Intentional expansion of the standardized interactive policy unless history says otherwise |
| Dev packages | `undollar`, `gnumake`, `just` in base | Moves these into dev and adds binutils, cmake, gdb, nix tools | Intentional ownership move and expansion of the dev policy unless history says otherwise |
| Zsh | Brew Zsh declared and HM Zsh configured | Nix Bash is explicitly selected; no HM/Brew Zsh policy | Intentional standardization on Bash |
| Spotify player | Enabled | No corresponding module | Task or intentional deletion |
| Nerd Font | Meslo package installed | Same Meslo Nerd Font appears in evaluated HM packages | Present |
| Discord | HM package in Darwin specialization | Darwin app-store Nix package | Changed ownership; verify GUI application exposure |
| Codex | Host-specific unstable override | Dev shell module imports unstable and enables Codex | Present conceptually; verify exact package source/version |
| Dotfiles sync activation | Out-of-store link plus `rsync` activation | Not present | Task: decide whether this impure self-sync behavior should be retired rather than ported |
| Home specialisation | Darwin default specialization auto-switch | Not present | Task: determine whether it served a real workflow; avoid restoring merely for parity |
| Manuals | HM HTML/JSON manuals enabled | Default HM behavior differs | Low-priority parity decision |
| Cachix module | User-specific Cachix config and package | Package in dev profile; no equivalent cache module found in host closure | Task: verify substituter/trusted key and auth behavior |

## Prioritized implementation tasks

### P0: make the target observable and buildable

- [ ] Add a bounded evaluation/check target for
      `darwinConfigurations.nixbook-pro.system.drvPath` with evaluation timing.
- [ ] Add `checks.aarch64-darwin.nixbook-pro` pointing at the system derivation,
      then wire the existing pre-push hook to that exact check.
- [ ] Capture a machine-readable baseline from the legacy target for packages,
      app-store entries, services, build machines, Nix settings, and selected
      Darwin defaults.

### P1: validate the virtual boundaries before filling gaps

- [ ] Document the intended contract of each virtual namespace (`shell`,
      `desktop`, `applications`, and similar): shared option topology, selection
      mechanism, and what must disappear from the realized closure when disabled.
- [ ] Verify that Bash selection leaves Nushell packages and configuration out of
      the realized Home Manager closure while preserving the merged shell option
      interface.
- [ ] Verify that disabled application variants and unused installation tools do
      not contribute packages or activation behavior to the Darwin system.
- [ ] Confirm that `workstation` is the intended policy selected by
      `nixbook-pro`; introduce a different profile only if the host should request
      a smaller policy bundle.
- [ ] Separate input adapters from capability interfaces. A backend should
      receive or declare only the input it uses, making later side-loading and
      backend repointing possible.

### P2: close required `nixbook-pro` behavior

- [ ] Decide and implement the Bash provenance conflict (Homebrew versus Nix).
- [ ] Decide whether Agenix is required for this host; if yes, select it as a
      system-secret backend independently of RBW.
- [ ] Port Colima/Docker as an optional virtualization capability, or record its
      retirement.
- [ ] Decide whether the macOS `container` package remains required.
- [ ] Verify Nix-installed Darwin GUI apps and decide whether `mac-app-util` or a
      replacement is required.
- [ ] Port or retire keyboard symbolic shortcuts.
- [ ] Verify the registry, Nix settings, local builder, and Darwin-default values
      against the legacy machine-readable baseline.

### P3: record package-policy decisions deliberately

- [ ] Preserve the encoded `safe-rm` decision/FIXME; do not restore it for
      package parity.
- [ ] Record the disposition of `has`; treat `procs` -> `procps` as an encoded
      consolidation unless contrary history says otherwise.
- [ ] Treat Nix Bash as the selected shell policy; do not restore Brew/HM Zsh for
      parity.
- [ ] Record whether `spotify-player` was intentionally dropped or replaced.
- [ ] Decide: legacy dotfiles sync activation and Darwin specialization.
- [ ] Review whether the expanded interactive CLI set belongs in the default
      shell policy or should be split into independently selected capabilities.

### P4: prove severability

- [ ] Add negative checks demonstrating that disabling a capability removes its
      package/runtime closure (for example Discord, Kitty, Colima, and Nushell).
- [ ] Keep shared virtual interface definitions available while asserting that
      inactive backend realizations do not affect generated configuration.
- [ ] Add an input-closure check or documented inspection command showing which
      flake inputs a minimal host actually requires.
- [ ] Exercise the same interfaces from generic Linux with different backend
      bindings; do not require the whole Darwin workstation profile.

## Suggested acceptance criterion for the first thin slice

The first slice is complete when:

1. `dendritic#darwinConfigurations.nixbook-pro.system` evaluates and builds.
2. The host explicitly selects its system, home, shell, terminal, browser,
   application-store, secrets, and builder capabilities.
3. Unselected backends remain available through their virtual interfaces but are
   absent from generated configuration and the runtime/store closure.
4. Every legacy delta above is marked ported, intentionally changed, or retired.
5. Generic Linux consumes at least the shared identity/shell/dev interfaces
   without importing Darwin realizations.
