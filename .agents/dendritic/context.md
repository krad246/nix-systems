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

The coexistence bridge is landed on `main` at `c116a095`. It consumes the
operationally frozen Dendritic flake and exposes its module registries beneath
`self.dendritic`, so
later slices can port capability cones without rebasing the reconstructed
branch or deleting unrelated legacy closures. The `dendritic` source is frozen
at `a99ff7e0` and tagged `dendritic-suspended-2026-08-12`; treat it as a
predecessor/source archive while migration proceeds from current `main`. The
lock file pins the exact commit; the input URL names the protected branch rather
than the immutable tag, so branch protection is part of the freeze guarantee.

“Frozen” is an operational stability state, not a ban on correcting code the
predecessor still owns. When migration uncovers such a defect, temporarily thaw
`dendritic`, repair and verify the authoritative implementation, update the
freeze coordinate/tag and bridge pin, then freeze it again. Do not internalize
or duplicate a capability merely to carry its repair; source-ownership transfer
is a separate landing justified by a coherent consumer cone.

Publish protected/frozen-branch repairs through pull requests. Prepare and
validate the complete final branch state, open a draft PR, promote/present it as
final when checks and review evidence are complete, then stop for the owner's
approval and merge. Do not bypass this by directly updating a protected branch.
Because a tag move is not itself representable in the PR diff, move the freeze
tag only after the owner merges the final PR that establishes its target commit;
then update downstream lock pins in a separate reviewable landing.

The active main-based migration branch owns the sole context-policy bundle.
The predecessor must not retain a divergent `.agents/dendritic` bundle or root
proxy after its next re-freeze. A repair performed in its worktree follows the
active branch's policy through that worktree/revision, then commits only the
predecessor source change and removal of stale policy copies.

The immediate sequence is now:

The 2026-08-13 cleanup landing is intentionally one review unit: remove the
leaking Colima/Lima stack, advance the bridge to the final merged predecessor
tip, finish the portable two-consumer HM proof, delete legacy `generic-linux`,
and synchronize all resulting context changes in the same PR. Do not publish
partial PRs from this lane; retain commit-level checkpoints on its branch.

1. completely port the standalone Home Manager `. #base` logical closure;
2. prove that same base module on aarch64-darwin and x86_64-linux and through
   both standalone and system-integrated consumers;
3. delete legacy `generic-linux` now that the portable cross-platform base and
   platform dispatch are proven. Preserve its desktop-only intent in the
   follow-on interface agenda rather than retaining the host-shaped
   implementation; current HM uses `targets.genericLinux`, while the final
   capability-level Linux/Darwin target vocabulary remains to be settled;
4. port Dendritic's redesigned flake-policy implementation instead of growing
   main's legacy checks/hooks into a competing architecture;
5. continue porting capability lanes and machine closures in coherent,
   independently mergeable commits.

The current highest-value landing hypothesis is a complete, correct, general,
and severable Home Manager substrate with two immediate consumers:

1. Home Manager integrated into `nixbook-pro` through nix-darwin;
2. a standalone Home Manager configuration.

Push as much of `nixbook-pro` as is genuinely user-space into this common HM
layer. The point is not to force system responsibilities into HM; it is to
isolate and prove the user-experience closure once, against two real
composition modes, before finishing the less-mature Darwin and host lanes.

The initial two consumers are the first proofs of the already-intended full
range, not a narrower final scope. The Home Manager trunk must support every
ordinary Darwin and FHS Linux instantiation through one standard construction
path. A host is a mergeable declaration over the module/profile namespaces,
not a bespoke call to `homeManagerConfiguration`, `darwinSystem`, or
`nixosSystem`. Windex must be restored through that path as an actual consumer;
merely making one generic Linux check evaluate is not completion. This is a
natural expansion of the same HM-first migration and federated architecture,
not a change of direction or a competing stack item.

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

The 2026-08-13 cleanup is an incremental contraction, not completion of this
policy. It reduces current `main` from 134 lock nodes/34 root inputs to 129/32
by deleting the obsolete `nixGL` and `nix-flatpak` roots and their five-node
closure. The contemporary Dendritic graph is 68 nodes/25 roots, so the later
flake-policy port still owns the larger auto-follow/auto-prune gap. Preserve
required capabilities rather than matching counts mechanically: `agenix-rekey`
is a current root consumed by the devshell and is absent from the predecessor,
so it must remain or be deliberately incorporated when porting that policy.

There is also a not-yet-realized ambition for flake-parts module-level
severability/applicability—ideas such as `importApplies` and related machinery.
Do not claim this exists today. Record cases where flake modules are resident or
applied too broadly so that a future substrate can make applicability explicit,
but do not block the HM landing on inventing the entire mechanism first.

Atomicity is semantic. A 150-line backend may be one correct capability. Ten
five-line files are still a monolith if they always activate together or can
only be consumed as a bundle.

### Federated kConfig direction and native Nix substrate

The broader architectural ambition is usefully described as reviving Linux
`kConfig` as a federated module-system architecture over `pkgs`, implemented
with Nix modules. Capabilities publish typed/mergeable declarations, multiple
independent contributors extend them, and an owning interpreter lowers the
completed namespace into package sets, modules, derivations, or platform
configuration. Unlike a single global kernel configuration, the system is
federated across nested module systems and package scopes; no central file must
know every capability or implementation.

This is a direction and evaluation model, not permission to invent one giant
framework before the HM bridge lands. The owner has a successful work
implementation as evidence that the model is viable, but this repository must
discover and land its interfaces incrementally through real consumers.

Preserve these substrate laws when extending the architecture:

- Dendritic is a composition property, not a directory convention.
- Prefer many contributors merging inert declarations followed by one owning
  interpreter. Late interpretation gives the completed virtual namespace a
  chance to reach a merge fixed point before lowering.
- A framework may validate, normalize, or synthesize public data, but it must
  not monopolize expression. A knowledgeable caller should be able to write an
  equivalent public attrset/module declaration with ordinary Nix.
- Higher abstractions must compose recognizable Nix machinery—module merging,
  overlays, scopes, `callPackage`, fixed points, derivation extension, and
  ordinary overrides—rather than hiding an incompatible parallel universe.
- Merge semantics are a primary API. Test two independent contributors,
  removal of an integration, replacement of a backend, and adversarial
  transformation order, not only a single happy-path configuration.
- Keep flake-level, NixOS/nix-darwin, Home Manager, and package-local module
  systems conceptually distinct. Similar module arguments do not make their
  fixed points, applicability, or ownership interchangeable.
- Choose outer versus inner `lib` and package scopes as part of the contract.
  Scope-sensitive dependencies must resolve through the intended derived
  package set; do not accidentally capture a convenient outer `pkgs`.
- Publish one coherent flake-level library as `self.lib`, derived from the sole
  followed Nixpkgs input. Use it for stable library operations and release
  metadata in published modules. Use a distinctly named inner/extended library
  only when its additional fixed-point behavior is required; do not couple
  stable consumers to the assumption that upstream symbols are re-exported by
  an overlaid `pkgs.lib`. Lexical capture of flake-parts' module argument is not
  a substitute for this public fixed point.
- Distinguish importing a definition from splicing a realized universe. A
  module, overlay, extension, factory, or constructor may come from another
  input and be applied inside this flake's fixed points; the resulting value
  must still descend from this repository's locked/followed input closure.
  Consuming another scope's already-realized `pkgs`, extended `lib`, module
  evaluation, or package instance instead imports that universe's identity and
  closure and must be an explicit interface decision. Prefer definitions and
  factories when establishing coherence; splice realized universes only when
  the semantic intent actually requires it.
- Reproducible coherence is a provenance property, not merely value equality.
  Cloning the repository and its lock must reconstruct every ordinary package
  set, stable library, and module-system input from the declared sole roots.
  Equal version/release strings do not prove this if parallel inputs or imports
  realized independent Nixpkgs worlds. Use follows relationships, flake-parts
  per-system fixed points, and overlay application to make provenance structural.
- Package-set identity is not the coherence invariant. Standalone Home Manager,
  integrated Home Manager, NixOS, nix-darwin, and flake-parts `perSystem` may
  deliberately instantiate distinct `pkgs` fixed points from the same followed
  Nixpkgs source. In particular, Dendritic intentionally leaves
  `home-manager.useGlobalPkgs` disabled so integrated Home Manager owns its
  package evaluation. Require every ordinary fixed point to descend from the
  declared source graph; do not replace that design merely to make the Nix
  values identical. Overlay, unfree, and platform policy may differ only where
  the owning context declares that difference intentionally.
- Reason about recursive package/module fixed points structurally. `final` and
  `prev` are semantic positions, not imperative time steps, and nested fixed
  points may behave like coupled gears rather than an inner computation that
  wholly finishes before an outer one begins.
- Preserve ordinary Nix as an escape hatch and keep public APIs semantic. Do
  not expose arbitrary fixed-point seeds, mirrored `finalAttrs`, or framework
  internals as the lasting contract.

Two longer-horizon research lanes came from the online architectural history.
They are durable context but are not prerequisites for the current HM bridge:

1. Hierarchical cross-package scopes must combine accumulated package-set
   transformations with child subscopes. The motivating form was an MSP430
   scope containing libc/runtime environments, MCU families, and concrete
   members. Plain nested attrsets solve only half the problem; descendants must
   inherit the relevant overlay/scope transformations, and the resulting
   public representation must remain hand-writable. The final schema,
   splicing, sysroot, toolchain, and node boundaries remain unresolved here.
2. Module-configurable packages may expose a semantic operation such as
   `pkg.withConfig moduleDelta`, returning another configurable package. The
   non-negotiable adversarial law, if this API family is used, is
   `withConfig A -> overrideAttrs B -> withConfig C`: `C` must forward-rebase
   from the package currently in hand so `B` survives. Static variants are not
   a substitute for dynamic rebasing. Historical `finalPackage` machinery is
   evidence of the stale-base bug, not an implementation prescription.

The same empirical method applies to future boot/provisioning design: derive
interfaces from materially different proof cases (EFI, supported BIOS/non-EFI,
encrypted/provisioned storage) instead of generalizing one working host. These
lanes are provenance-preserved research, not current landing scope.

### Supplemental online-context reconciliation (2026-08-12)

The owner supplied an online architectural synthesis and proxy bundle as
historical context. Source fingerprints at import time were:

- `AGENTS.md — nix-systems Architectural Intent.md`:
  `7c1b276e04103f0a88df95590355f7b2173ef8b933bceae8d32e12aef6d83060`
- `dendritic-online-context.tar.gz`:
  `82ff3a71627437710830450fcc45553c49be158364e485d958e1dd6fd6c3cfb2`

The source files lived in the owner's Downloads directory and are not required
for replay. The accepted, non-duplicative semantics are normalized above so
this committed bundle remains self-producing. Provenance is
`candidate online history, reconciled by local Codex on 2026-08-12`; current
committed local context and later owner decisions remain authoritative.

Do not resurrect the online bundle's stale uncertainties. Local context has
already settled the input/follows priority, vTable framing, profiles as
presets, trunk bridge, HM-first lane, sysroot/input registry, closure taxonomy,
and current removals. Its tentative Helix-under-interactive-shell placement is
not accepted; editor remains a separately reasoned capability. Its browser,
fonts, desktop, applications, identity, secrets, and remote-builder gaps convey
no design recommendation beyond the explicit local decisions in this file.

The import added no reason to reopen the current HM closure choices. It adds
composition laws and distant research lanes; it does not enlarge the first
bridge slice.

### Profiles

Profiles are intentionally opinionated presets. They compose through imports
and enable/default declarations, ordinarily using `mkDefault` so callers can
replace selections. Do not criticize a profile merely for choosing Bash,
Helix, FZF, Kitty, or Zen. Do flag a profile if selecting one intended lane
activates unrelated capabilities or prevents backend substitution.

The exported Home Manager `base` profile intentionally provides interactive
training wheels: its interactive mode defaults on so the result is immediately
workable, but a consumer may carve it down with a stronger option definition.
Explicitly importing the `interactive` profile is the strong symbolic selection
that turns the same mode on non-defaultly. Capability/interface modules beneath
these profiles remain independently importable; do not confuse an opinionated
profile selection with an interface intrinsically enabling its backend.

Keep these categories conceptually distinct:

1. interface modules define vTables/contracts;
2. backend modules realize a contract;
3. integration modules connect contracts;
4. profiles/presets import coherent capability sets and select defaults;
5. hosts supply machine facts and exceptional policy.

### Host declarations and late interpretation

Host declarations are configurations of the same import-composed and
enable-composed profiles published through the namespace vTables. They must be
federated flake-level data: independent contributors may merge host facts,
profile selections, overrides, overlays, and rare exceptional modules before
one owning interpreter lowers the completed declaration into a NixOS,
nix-darwin, or standalone Home Manager output.

The lasting host API must not require a central hostname switch or a
hostname-specific constructor. Profile selection must be open over the
published module namespace rather than represented by a closed factory option
for every known profile. Adding a host or profile must not require editing the
interpreter. Constructor choice and Darwin/FHS-Linux platform adaptation belong
below the host boundary and must use this repository's followed input closure;
host declarations should ordinarily contain only identity and machine facts,
symbolic profile selections, and explicit overrides or overlays. Reusable
implementation code in a host declaration is evidence that a capability,
profile, or platform adapter is still missing.

The first implementation must prove the merge API, not only the happy path:
two independent contributors to one host survive the fixed point, unknown
profile names fail before construction, explicit selections can replace
profile defaults, and the same Home Manager profile modules work through both
standalone and system-integrated consumers. Windex is the first missing Linux
consumer proof, while Darwin and generic FHS Linux must share the same standard
Home Manager construction semantics.

The host interpreter is intentionally a repository-owned hybrid of the useful
public semantics in the flake-parts ecosystem's `easy-hosts` and `ez-configs`
adapters. Preserve `easy-hosts`-style mergeable shared, per-class, per-system or
architecture, and multi-tag contributions, together with `ez-configs`-style
host/user/output projection, but do not inherit either implementation's
filesystem discovery, implicit defaults, closed assumptions, or realized input
universes. Hand-roll the small flake module around ordinary typed options and
this repository's coherent constructors.

The declaration's semantic unit is not merely one hostname mapped to one
system output. One completed declaration may project into N deployment and
build outputs: the primary switchable system configuration, system-switchable
specialisations, image or other build variants, standalone and integrated Home
Manager activations for concrete users, and deployment records. These are
named projections of the same merged intent, not independently maintained host
copies. Design option syntax around the distinctions among profiles,
specialisations, variants, users, artifacts, and deployments; do not flatten
them all into tags or a raw module list merely because an upstream adapter does.

Do not begin that host/deployment framework until the lowest-tier Home Manager
composition vocabulary is complete enough to consume. First express and prove
the portable terminal range entirely through ordinary Home Manager module
imports and option configuration. Treat existing Dendritic profile names as
candidate mirrored standalone presets where the name represents genuine HM
semantics: `base` is the portable CLI home, `interactive` is its strong
interactive selection, and `dev` adds development/editor intent. `base` remains
a reusable module substrate but need not be a public output configuration. A
concrete standalone configuration is an evaluated root; derived configurations
such as `dev` must use that result's `extendModules` operation with the profile
delta, preserving package/module provenance and making the derivation
relationship explicit. Home Manager's own specialisation machinery is evidence
for this construction model, not a requirement to rebuild each variant from
the constructor. Do not publish a redundant HM configuration merely for name
symmetry—`homeManager.headless` currently adds nothing beyond `base`, while its
distinct `terminfo` behavior is system-owned. Rich workstation/desktop profiles
remain later tiers.

Variant declaration and materialization policy are separate. The flake-level
`dendritic.configurations` `attrsOf` registry stores each root once; its typed
`users` and `hosts` contexts carry the relevant constructor arguments and
`attrsOf` module-list deltas. Their defaults live beneath
`dendritic.defaults.users` and `dendritic.defaults.hosts`, while each
selected context and each variant may override standalone output and specialisation inclusion.
A standalone variant exposes an independently buildable output; inclusion projects the
same delta into the root's native `specialisation` namespace for runtime
switching. Effective policy is read directly as leaf override, then context override,
then global context default; implementations must not normalize a shadow declaration
attrset. The four combinations—neither, standalone only,
include only, and both—and mixed leaf selections must work without duplicating
declarations. The production default is standalone on and inclusion off.

The concrete Home Manager, NixOS, and nix-darwin evaluators use the module-style
`standalone` and `includeSpecialisation` options. Keep those evaluators as explicit
recursive attrsets rather than hiding their native contracts behind a backend
factory. Their materialization law is: construct one base configuration,
optionally include selected deltas in the root's native `specialisation`
namespace, and independently extend the same base configuration for every
standalone delta. An evaluator without native specialisations still supports
standalone variants and fails only when a selected coordinate requests inclusion.

Do not place the exhaustive four-mode proof in ordinary flake `checks`:
`nix flake show` enumerates checks and would thereby force the resident
specialisation lane even when production selects standalone-only. Exercise that
truth table through the Dendritic test flake modules. They contribute proper
per-system `dendritic.assertions`, `dendritic.warnings`, and
`dendritic.traces`; one assertion runner emits their check only when the
flake-parts `debug` option is enabled. Ordinary output enumeration therefore
keeps the unused runtime vTable lazy, while debug evaluation exercises the
four-mode matrix, host/image contracts, and nixbook-pro closure parity.

Standalone variant names are generated from their root and local variant names
through `dendritic.outputs.nameFunction`, following ezConfigs'
established naming-interface vocabulary. Its default is
`configuration: variant: "${configuration}-${variant}"`, yielding names such
as `standalone-dev`; native specialization tables continue using the local
`dev` key. Generated names must be unique and must not collide with root names.

Standalone variants always extend the unspecialised evaluated root and retain
the complete `homeManagerConfiguration` result, including its ordinary
`extendModules` operation. This is the lightweight, independently buildable
view. Included specialisations are a separate heavier projection of the same
module delta. When both are selected they may perform distinct evaluations,
but equivalent declarations must resolve to the same activation derivation.
Do not replace the standalone result with a thin adapter over Home Manager's
included `config`; that loses the normal Home Manager result interface and
couples publication cost to the resident specialisation table.

The unified configuration interpreter is a sparse projection matrix rooted in
one cleanly assignable, mergeable RAII-like declaration attrset. That single
public ownership boundary must address every layer rather than exposing
parallel Home Manager and system declaration registries. Its typed coordinates
include root intent, standalone and integrated users, build/evaluation
platform, target platform, variant and specialisation deltas, projection
backend, images and other outputs, and publication/embedding policy. NixOS,
nix-darwin, standalone Home Manager, integrated Home Manager, generator images,
specialisations, and deployment records are projections of the completed
declaration rather than bespoke host constructors. Backends remain open
registries; enabled coordinates alone materialize, so a wide declaration space
does not force the full Cartesian product. Include/embed rules are explicit
performance controls: they determine whether a lightweight independent output,
a heavier resident specialisation, both, or neither is materialized at each
coordinate.

Cross compilation is a relationship between build and target platforms, not a
free-floating boolean substitute for them. A hierarchical `cross.enable`
policy may globally prohibit or permit cross projections and allow narrower
root/variant/artifact overrides, but each selected projection must still name
or derive its build and target platforms explicitly. Native means those
platforms coincide; cross means they differ. Keep target `pkgs` distinct from
host-side generator/runner `pkgs`, while deriving ordinary package universes
from the same declared Nixpkgs source graph.

The unified system declarations now expose `buildSystem = null | system` and a
hierarchical `cross` gate. Null build coordinates mean native construction for
each listed target; a differing build/target pair is rejected unless the
declaration inherits or overrides `cross = true`. The constructor injects the
build platform only for that permitted relation, preserving target platform as
the system output coordinate.

The earlier `dendritic.systems.configurations` slice proved system projection
mechanics but is no longer the public boundary: it and the parallel Home
Manager registry are folded into the single `dendritic.configurations`
declaration attrset described above. A declaration may list multiple target
systems and assign modules, users, variants, specialisations, images, and
projection policy at the appropriate nested coordinates. An internal
platform-inspection interpreter selects NixOS or Darwin construction; that
backend distinction is deliberately absent from public declaration data. The
`generic-headless-interactive` NixOS declaration demonstrates both an additive
`dev` variant and an embedded `vm-nogui` artifact-module variant. The published
VM variant remains a full NixOS result; its image is a later artifact projection
of that result, while the root's native specialisation is the runtime view.
An artifact declaration names that variant and an attribute path; `perSystem`
materializes it for the matching build coordinate. Thus
`generic-headless-interactive-vm-nogui-x86_64-linux` is a package projection of
`config.system.build.images.vm-nogui`, not a second system declaration.
System declarations also accept named `users.<name>.modules` deltas. The
selected evaluator injects these into its integrated Home Manager namespace;
the composed Darwin proof host contributes a user delta without re-importing
the workstation's already-owned shared HM profile module.

The nixbook-pro closure proof now makes user ownership explicit rather than
letting `darwin.workstation` inject the complete Home Manager stack. One shared
user-intent module list owns the desktop, development, interactive, secrets,
and default-browser selections. A `nixbook-pro.users` standalone root composes
that list with the standalone constructor, while
`nixbook-pro-composed.hosts.users.krad246` injects the same list into the host.
The host imports only its Darwin-side application-store, browser, base,
builder, and networking responsibilities. Parity checks compare both new
consumers with the pinned legacy nixbook-pro user for identity, state,
program/profile selections, integrated package paths, standalone package names,
managed-file keys, XDG-file keys, and session variables. The standalone inventory additionally owns the
`home-manager` CLI package that the integrated host supplies; exclude only that
known construction-boundary difference when comparing package paths. Do not
require the standalone and integrated `TERMINFO_DIRS` values to be identical:
they correctly point at the user profile and system-owned per-user profile,
respectively. Do not require identical activation derivation paths:
Home Manager integration metadata such as the backup revision legitimately
depends on the evaluating flake even when those semantic inventories match.

The current-tree flake module now owns the Home Manager identity defaults,
portable base policy, standalone constructor support, and the desktop, dev,
interactive, and secrets profile compositions used by these declarations.
Only their lower-level feature primitives—input registry, shell, browser,
terminal, editor, and rbw—remain behind the pinned Dendritic migration seam.
Preserve the pinned substrate release for `home.stateVersion`; the current
unstable Nixpkgs library may advertise a newer release than the selected Home
Manager supports, and state versions are compatibility contracts rather than
upgrade indicators.

As a temporary 2026-08-28 CI boundary, legacy Fortress generator packages and
VM apps, legacy ezConfigs Windex/Fortress roots, and the new non-deployable
generic NixOS roots are omitted from ordinary flake output discovery. They
forced known legacy IFD/assertion failures or boot assertions unrelated to the
unified interpreter. The directly materialized generic `vm-nogui` image package
and isolated system-projection test remain active. Restore NixOS configuration
publication only after `hosts` declarations distinguish deployable roots from
image-only composition substrates; restore Windex and Fortress through that
interface rather than re-enabling their legacy projections.

Current supported flake-parts enumeration deliberately filters out
`x86_64-darwin`: Nixpkgs unstable no longer supports it after 26.05. Keep the
FIXME until a pinned legacy package universe or an explicit compatibility
backend justifies restoring that coordinate. The legacy `fortress-disko-vm`
package/app exposure is likewise disabled until the generator projection
backend owns it; do not revive it as another bespoke per-system exception.
NetworkManager's NixOS module owns its wpa_supplicant relationship—the portable
base must not independently set `networking.wireless.enable` and conflict with
image modules.

Embedding intentionally pays an evaluation and closure-residency cost because
Home Manager's native specialisation implementation forces every registered
variant activation while producing the parent generation. These are global
orchestrator policies, not properties repeated by individual roots or variants.

Measured evidence on 2026-08-13 with the flake evaluation cache disabled:
standalone stabilized near 3.6 seconds, a separately published `dev`
`extendModules` result near 4.0 seconds, the parent with embedded native
`specialisation.dev` near 5.4 seconds, and extending that specialized parent
again near 6.2 seconds. The implementation cause is not specialization as a
semantic concept: Home Manager's parent activation enumerates specialization
activation packages to construct its link farm, thereby forcing another module
fixed point for each resident variant. Recheck this policy if Home Manager gains
lazy/on-demand specialization projection or Nix module evaluation gains an
applicable incremental-sharing mechanism.

The per-root/leaf policy refactor was remeasured on 2026-08-27 against the real
standalone development composition with the evaluation cache disabled. The
independently published `standalone-dev` activation evaluated in 6.10 seconds;
the parent activation with the same `dev` delta embedded evaluated in 9.19
seconds. Absolute times vary with machine and branch state, but the result
supports retaining publication as the lightweight complete Home Manager result
and treating embedding as an explicitly heavier runtime projection. The
isolated evaluator also proves that the published and embedded dev activations
have the same derivation when their declarations match.

Keep portable profile semantics distinct from target realization, but do not
over-separate harmless Home Manager target defaults. The owner accepts
`targets.genericLinux` as a soft default for every Linux Home Manager context:
it works on generic FHS Linux, NixOS, and WSL. Preserve an ordinary stronger
override path rather than moving the setting solely to standalone construction.
WSL is an integrated NixOS consumer of the same portable terminal profiles plus
its own system/platform capabilities; it is not another copy of the removed
Generic Linux host bundle.

This low-tier matrix must cover concrete users and Darwin/FHS-Linux targets,
including SSH/terminal and builder use cases where those consumers genuinely
have managed home environments. Prove interface imports, preset selections,
overrides, and closure removal here. Once those HM compositions are stable,
hosted systems should import the same modules symmetrically; the later
N-output host interpreter then performs projection rather than inventing user
environment semantics.

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

### Flake policy and output surface

Dendritic's redesigned flake-level policy is the durable implementation to
port. Do not elaborate `main`'s legacy checks and hook machinery into a new
general framework during migration. Preserve existing behavior, add only
narrow and conspicuously disposable bridge glue where an immediate proof is
needed, then replace that glue by consuming the Dendritic policy interface.

A large, expressive flake output surface is desirable. The architectural
problem is not output count; it is accidental declaration, ownership,
composition, and consumption semantics. Retain or rebuild useful outputs behind
the redesigned Dendritic module/policy structure. Never use schema shrinkage as
a proxy for architectural quality.

Treat `nixConfig` as repository execution policy, not host daemon policy. It
should make evaluating and building this flake reliable and efficient across
heterogeneous development machines by declaring required features, public and
private caches/keys, substitution/fallback behavior, portable autoscaling
defaults such as `cores = 0` and `max-jobs = auto`, and bounded connection plus
long-running build/silence timeouts. Keep trusted users, build users, sandbox
policy, store retention/free-space policy, remote-builder topology, and other
machine facts in system capabilities. Ambient/user CLI configuration may
override the repository preset.

Use flake-parts partitions to separate expensive or specialized output lanes
when their real input/evaluation cones justify it. The partition module is
already imported on the main-based branch; turn that substrate into meaningful
boundaries rather than cosmetic partitioning. A partition should reduce the
inputs and modules forced by ordinary evaluation while preserving the rich
output surface and an obvious consumer path.

Terraform the main-based `flake.lock` incrementally toward Dendritic's disciplined
graph as capability lanes land. For each coherent port, identify which inputs
still have consumers, remove obsolete declarations only after those consumers
move, apply explicit `follows`/deduplication, and prune nodes that become
unreachable. Do not copy Dendritic's older lockfile wholesale or optimize for a
node-count target. Every lock change must be attributable to a source consumer,
partition boundary, or follows relationship and verified through the affected
outputs. Large portions of the graph should disappear naturally as legacy
frameworks and output lanes become worthless to the successor architecture.

For the initial HM base port, retain `check-flake` and `check-flake-file`
unchanged. A separate temporary `realize-dendritic-hm-base` pre-push hook may
refer symbolically to `config.checks.dendritic-hm-base.drvPath`, discard its
string context so hook installation does not realize it, and invoke the wrapped
Nix distribution supplied by the devshell. Delete this hook when the HM/policy
port supersedes it. Do not replace it with `nix flake check`, `nix build
.#base`, or a generalized map over the checks namespace.

## Branch topology and migration hazard

Current durable coordinates as of 2026-08-13:

- frozen predecessor branch: `dendritic` at `a99ff7e0` (merged PR #446; its
  coherent-library prerequisites were merged as PRs #443 and #444);
- frozen tag: `dendritic-suspended-2026-08-12` at `a99ff7e0`;
- bridge landed on `main`: `c116a095` (source bridge commit `b341ba3c`);
- current main-based cleanup/migration branch: `drop-colima-lima-stack`, based
  on `main` at `af7a4b8f`; it is the single review unit for the 2026-08-13
  cleanup sequence recorded above;
- initial cross-platform HM base commit: `7ba2dae3`;
- the Home Manager input-registry cone remains predecessor-owned; its public
  path was repaired through PR #435 and subsequently re-frozen at `a99ff7e0`;
- the Dendritic branch was reconstructed through roughly one hundred small
  sequential commits, beginning with `Clean everything out` and rebuilding the
  flake and modules from a blank baseline.

Always re-check these facts. They are historical coordinates, not permanent
truth. Use `git status --short --branch`, `git branch -vv`, `git worktree list`,
and `git merge-base main dendritic` before acting.

Keep migration and controlled predecessor-thaw work in dedicated temporary
worktrees rather than moving it into the owner's primary
`/Users/krad246/.config/dotfiles` worktree. The temporary names may be awkward,
but their isolation protects the primary checkout and makes branch ownership
explicit throughout the bridge effort. If the owner later proposes removing
them early, remind them of this recorded decision and recommend retaining the
isolation; the owner may explicitly override it. Perform the final primary-
worktree changeover only after the predecessor repository/bridge machinery has
been completely eliminated and the migration is ready to replace it.

The branches also differ in dependency era. Current `main` uses 26.05 inputs,
while frozen `dendritic` uses 25.11 for Nixpkgs, Home Manager, and nix-darwin.
Never treat lockfiles or generated `flake.nix` as mechanically interchangeable.
Do not solve this with a giant rebase. The landed predecessor bridge exists to
make coexistence and incremental ports possible.

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
   - Darwin `apps`, `base-configuration`, `macos-container`, and
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
- Colima/Lima is an accepted repository-wide removal. On 2026-08-13 the owner
  directed removal of the whole Darwin Colima/Lima stack after the launchd
  `KeepAlive` service repeatedly orphaned `.limactl-wrapped` processes under
  PID 1 until the host exhausted its process limit. Do not restore the module,
  host selections, packages, or launch agent as a Generic Linux parity item.
- `macos-container` is intentionally excluded from this port.
- Using Nixpkgs `bashInteractive` instead of the Homebrew Bash is acceptable for
  the narrowed slice.
- Homebrew itself is not forbidden. It may remain or return behind a sound
  capability; it was initially narrowed out because of porting friction.
- Profiles are presets and may compose through imports and enable/default
  declarations.
- Hosts are mergeable, nearly code-free declarations over namespace vTables.
  One late interpreter owns constructor and platform dispatch; do not add
  per-host constructors, a central hostname map, or a closed profile schema.
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
| HM bridge package universe | deliberate separate fixed point; policy audit remains | Old had `useGlobalPkgs=true`, `useUserPackages=true`, `verbose=false`; Dendritic intentionally leaves global pkgs off, uses user packages, and is verbose. Its private HM `pkgs` evaluation must descend from the same followed Nixpkgs source, but need not be the identical system or `perSystem` fixed point. Audit overlay/unfree/platform policy without reopening that ownership decision. |
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
Main previously included Colima and Docker through its Colima module; that
entire Colima/Lima stack is now an accepted removal after a demonstrated host
process leak. The separate macOS container package remains outside the HM port.
Main includes system Agenix and Lorri; Dendritic does not. Dendritic adds
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
| input flake registry | architecturally superseded/win; bridged from predecessor | Both expose registries. Dendritic replaces old `flake-registry` with the generic configurable input-registry source and locked/unlocked behavior. Main now consumes it through the exported Dendritic `base`/`standalone` profiles rather than reconstructing the cone. |
| registry filesystem projection | changed, capability available; path repaired | Main installs `~/nix/path/*` links unconditionally via `home-link-registry`. Dendritic has `input-registry.sysroot.install` and optional search-path projection, currently disabled for this consumer. PR #435 repaired its public absolute path from `/Users/krad246/./nix/path` to `/Users/krad246/nix/path` at the authoritative predecessor source. Selection policy remains to decide. |
| dotfiles link/sync | accepted removal | Do not port the mutable synchronization/link behavior. |
| XDG | preserved | PR #446 moved `xdg.enable=true` into the authoritative Dendritic `base`; both standalone and integrated bridge consumers now inherit it. |
| manuals | preserved foundation policy | PR #446 established HTML false and JSON true in Dendritic `base`, independently of browser integration. |
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
- Colima/Lima is intentionally removed repository-wide; `macos-container`
  remains intentionally excluded from the HM port;
- application tools eventually activate from resolved demand, not mere
  availability;
- remote-machine definitions are rearchitected rather than silently lost;
- the slice can merge without deleting unrelated legacy hosts/closures;
- the low-level HM layer has standalone and integrated composition evidence;
- input-version differences are resolved intentionally, not hidden by lockfile
  churn.

## Bridge-to-main constraints

The bridge landed on `main` at `c116a095`. Preserve these constraints as later
ports extend it:

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

Success means ordinary work proceeds in a trunk-based rhythm: introduce or
polish one capability cone, integrate it with one or more real consumers, verify
it alongside untouched legacy closures, and merge it to `main`. A bridge that
still requires carrying a broad shadow tree, periodically rebasing the entire
`dendritic` rewrite, or deleting legacy exports before their consumers move is
not a successful bridge.

### Operational trunk migration loop

Apply the bridge repeatedly as a consumer-driven closure migration:

1. choose the smallest coherent capability cone needed by a real consumer,
   starting with the complete standalone HM `. #base` logical closure;
2. consume the frozen predecessor's virtual interfaces through `self.dendritic`
   while defining main-owned replacements at the same registry boundary;
3. reconstitute the target consumer from capability imports and prove behavior,
   backend replaceability, and derivation closure on the current main-based
   branch;
4. deactivate or remove only the corresponding legacy `ezConfigs` code path and
   old modules whose consumer count has reached zero; unrelated legacy hosts
   and closures remain live;
5. once a capability cone is proven, internalize/move its required module
   sources into the current tree so main no longer depends on the predecessor
   for that cone;
6. merge the independently coherent slice to main and select the next consumer
   cone rather than accumulating a second long-lived integration branch;
7. repeat until `ezConfigs`, predecessor registries/input, and compatibility
   adapters have no consumers;
8. delete `ezConfigs`, the Dendritic bridge/input, temporary realization hooks,
   and frozen-branch migration machinery as final cleanup—not before.

Large deletions are therefore amortized by consumer migration. Never mirror the
feature branch's original mass deletion onto main, and never require Dendritic
to rebase over ongoing main development. Near the endpoint, the accumulated
main tree becomes the successor architecture and the frozen branch ceases to be
a dependency; this is a sequence of source-ownership transfers, not a final
giant branch merge.

Do not confuse source repair with source-ownership transfer. Fix a defect in a
still-predecessor-owned capability through controlled thaw/re-freeze; transfer
that capability only when its consumer cone, boundary proofs, and commit scope
independently justify internalization.

A likely continuation sequence, subject to evidence, is:

1. finish the main-owned cross-platform HM `base` and standalone shell;
2. identity and low-level shell program interfaces;
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

The owner permits bounded asynchronous sub-agent work for mechanical context
checkpointing and propagation, cache-mirror verification, periodic recovery
maintenance, and similarly isolated validation tasks. The primary agent retains
architectural judgment, conflict resolution, and ownership of the active
implementation lane. Before delegating shared-worktree mutations, assign
non-overlapping files or make the sub-agent read-only; never allow concurrent
agents to race on the canonical bundle or generated projections.

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

#### Write-through cache and cross-machine continuation

Use a deliberately simple single-writer, write-through coherence model. The
repository bundle is authoritative memory; local Codex project-charter files
are disposable read caches. There is no peer-to-peer merge protocol and no
cache may become an independent source of truth.

For every durable architectural memory write:

1. edit `.agents/dendritic/context.md`, its routes, template, or supporting
   bundle files first;
2. run `.agents/dendritic/context.sh refresh`, which regenerates the proxy hash,
   root `AGENTS.md`, manifest, and local project-charter mirrors;
3. run `verify` and `verify-cache`;
4. commit canonical and generated repository files together with the embodying
   implementation, or in an immediate context-only commit;
5. push the commit before relying on another machine/model to remember it.

If an agent or human has already mutated a local cache file, do not run a sync
that overwrites it blindly. Diff it against canonical context, reconcile every
durable non-stale fact into the appropriate canonical sections, then refresh.
Cache-only changes are dirty, non-durable writes and must not survive the turn.

To continue on another computer or with another Codex instance:

1. clone or pull the repository branch containing the newest context commit;
2. read root `AGENTS.md` and run `.agents/dendritic/context.sh verify`;
3. run `.agents/dendritic/context.sh sync-cache` followed by `verify-cache`;
4. run `.agents/dendritic/context.sh full` before architectural work, or read
   only routed sections for bounded implementation after full context has been
   established;
5. inspect current Git/evaluation state because recorded coordinates are
   historical evidence, not a substitute for the live tree.

This is write-through, not eventual consistency: a decision that affects
subsequent work is synchronized before that work continues. Commit + push is
the publication boundary; merely changing model memory or a local cache is not.

Long-running agent sessions have intermittently exhausted file descriptors.
Until the leak is fixed, periodically checkpoint durable progress through the
normal write-through path—canonical bundle first, then refresh, verify, commit,
and push—so a cache flush or process restart has a recent recovery point. Do
this after meaningful architectural/ledger milestones and before any planned
flush; do not let an extended implementation session accumulate important
context only in conversation or local caches. A cache flush is operational
recovery, not publication, and does not replace the canonical checkpoint.

`nix run .#agent-checkpoint` is the stable mechanical entry point. Keep that
public command generic: today it delegates to the Dendritic bundle's
`checkpoint` primitive, but future agent-maintained internal documentation may
replace or extend that storage without renaming the lifecycle action. A matching
Just command namespace is a possible convenience layer, not current scope.

The `agent` devshell exposes `verify-dendritic-context`, and the same executable
backs the scoped `verify-dendritic-context` pre-commit hook. The hook is
read-only: it runs when the canonical bundle or generated `AGENTS.md` changes
and rejects stale hashes/proxies. Refresh remains an explicit checkpoint action
because commit hooks must not silently rewrite architectural state.

Bootstrap and recovery tooling follows one boundary: statically close over
tools and immutable logic; late-bind mutable workspace locations and recovery
inputs. Nix applications should capture executables, libraries, and exact script
implementations through typed derivations/store paths, but must not capture an
immutable source-store copy as the writable checkout. Resolve mutable roots in
this order: explicit command argument, then an invocation-local fallback such as
the live script location or `$PWD`/ancestor discovery. Use an environment
override only when the tool's actual mutable-state contract requires
coordination with external shell state; do not inherit one merely because a
devshell exports it. Validate the selected root, expected markers, bundle
contents, and root/bundle coherence before mutation.

Keep the underlying recovery primitive directly runnable with a baseline shell
and explicit arguments when `direnv`, the development shell, or repository PATH
setup is broken. Nix apps and Just recipes are typed/convenient front doors over
that primitive, not its only execution path. Ambient environment is an override
and recovery seam only for tools that deliberately support it, not a substitute
for statically declaring ordinary tool dependencies or local target discovery.

Treat an exported environment variable as publication onto a process-tree
software bus: downstream programs consume it implicitly. Publish uppercase or
exported state only when that bus is an intentional, documented contract with
real consumers. Otherwise keep implementation state in lowercase shell-local
variables. Prefer explicit arguments, structural location, or typed inputs over
reading ambient bus values; stale environment inherited from another devshell
or worktree must not redirect bootstrap or mutation targets.

The repository uses manual nix-direnv reloads after initial bootstrap.
Automatic reload of an established cache has caused persistent reload churn,
so do not force a rebuild on every shell entry. A fresh worktree with no cache
for its selected devShell must bootstrap itself automatically on first entry;
manual policy begins only after both its exact profile and profile RC exist.
Lorri is an exploratory asynchronous publisher of richer devshell state and is
useful but not yet a settled replacement. Preserve the current manual contract
and revisit reload/publisher behavior in a separate lane rather than coupling it
to bootstrap or hook-installation fixes.

The intended follow-on direction is to remove Lorri rather than harden its
opaque per-project cache. Investigate process-compose or another modular
flake-owned services interface through which the repository can declare and
orchestrate its development service fleet. Keep the interface choice open until
the required service contracts are inventoried; `process-compose` is a candidate
backend, not the public architecture. Prefer checkout-local, declarative,
disposable runtime state so recovery of repository-owned state is equivalent to
cleaning the checkout and re-entering it. Secrets, user data, and intentionally
external service state remain outside that cleanup boundary and require explicit
lifecycle contracts.

When a Git hook in an isolated worktree reports missing repository environment
state (for example, a pre-commit shim sees no generated hook configuration),
enter the worktree through direnv. A cold worktree must build its first cache
without an extra command; an established but stale cache requires the generated
`nix-direnv-reload` helper. Retry the operation through `direnv exec .` and let the
repository hook suite run. Do not default to `PRE_COMMIT_ALLOW_NO_CONFIG=1` or
another hook bypass for this case.

Checkpoint/propagation work may run in a bounded sub-agent while the primary
agent continues an independent implementation lane. Treat the canonical bundle
as single-writer state: delegate either the complete checkpoint operation or
read-only verification, and do not concurrently edit its inputs or generated
outputs from another agent.

Parallel implementation agents must own distinct worktrees and branches. Fetch
and verify the expected remote tip before publishing, then push with both
`--force-with-lease` and `--atomic`; never let parallel agents publish to the
same branch.

Treat legacy Generic Linux behavior as decision evidence, not an architecture
to reproduce verbatim. Before migration or deletion, inventory the delta from
the new Home Manager base and classify each item as portable intent,
platform-specific implementation, or incidental legacy choice. Port only after
an explicit owner retain/redesign/drop decision. In particular, Kitty is a
potential backend of a terminal interface that can also admit Ghostty,
Alacritty, and other implementations; it is not itself the portable interface.
VS Code, VS Code server, and their related integrations are deferred outside the
current migration scope. Preserve their legacy source locations in the decision
inventory, but do not port them or treat them as parity or deletion gates.

The owner accepted deletion of legacy `generic-linux` before its desktop-only
behavior is redesigned. This deletes implementations, not capability intent:
the removed sources remain decision evidence for later ports. Flatpak
install/update policy, conditional dconf, desktop-entry visibility, Linux
desktop presets, terminal-backend selection, and VS Code/server integration are
explicit follow-on interface-design lanes. They are not portable-base parity or
deletion gates; Kitty remains an optional terminal backend rather than the
portable interface. Do not recreate the deleted host-shaped bundle merely to
restore these behaviors.

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
5. run `.agents/dendritic/context.sh refresh` to regenerate the manifest, root
   `AGENTS.md` proxy hash, and local cache mirrors;
6. run `.agents/dendritic/context.sh verify`, `verify-cache`, route-expansion
   checks, shellcheck, and `git diff --check`;
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

1. Finish total behavioral porting of `. #base`, using the program-by-program HM
   ledger and explicit owner decisions rather than copying legacy bundles. The
   bridge now consumes the predecessor's exported `base` and `standalone`
   profiles directly; do not reconstruct their imports locally.
2. Keep the evaluated cross-platform base checks meaningful without requiring
   `base` to remain a public configuration name. A concrete standalone root may
   privately import the reusable base module and publish its activation as a
   pure per-system artifact plus an impure local convenience output. Derived
   configurations such as `dev` use `extendModules` on that evaluated root.
   During this migration, the temporary pre-push hook realizes the exact
   selected check derivation while legacy `check-flake` remains intact.
3. Build and prove the complete low-tier Home Manager preset matrix before the
   host framework. Derive `dev` from the evaluated standalone root with
   `extendModules`, and reconcile WSL as an integrated NixOS consumer of the
   same portable terminal modules. The soft `targets.genericLinux` default may
   remain active in all Linux contexts. Add any distinct
   SSH/terminal or builder user-space composition only when justified by real
   consumers; do not mirror semantically empty profile names for symmetry.
4. Add the federated N-output host/deployment registry and its single late
   interpreter, then restore Windex as a consumer through it. Use the already
   proven Home Manager modules for standalone, nix-darwin-integrated,
   NixOS-integrated, and generic FHS Linux instantiations; host declarations
   should contain only facts, profile selections, and explicit
   overrides/overlays. Legacy `generic-linux` remains deleted; its deferred
   desktop behavior stays in the interface agenda rather than returning as a
   host bundle.
5. Port the Dendritic flake-policy interface, retaining a rich output surface
   while redesigning declaration/ownership/composition semantics.
   Inventory and eliminate every import-from-derivation consumer, especially
   legacy Fortress image/application projections, then enforce
   `allow-import-from-derivation = false` as repository execution policy. The
   owner does not claim IFD is universally incorrect; this repository bans it
   because its forcing behavior and evaluation cost undermine shallow discovery
   such as `nix flake show`. Do not enable the ban while known required outputs
   still depend on IFD; a future exception requires an explicit policy change.
   In the same audit, remove non-flake evaluation-time fetchers such as nested
   `fetchTarball`/`fetchGit` calls that hard-code and shadow declared inputs.
   These are provenance violations often introduced to compensate for missing
   propagation from the flake-parts fixed point into Home Manager or system
   modules. Replace them with sole-root followed flake inputs and propagate
   definitions through published modules, lexical flake scope,
   `moduleWithSystem`, or typed options—not `specialArgs`. After migrating known
   consumers, add a repository check that rejects new shadow fetchers.
6. Continue normalized old/new `nixbook-pro` behavioral diffs, Linux-builder
   parity, and remote-definition intent inventory as their dependency lanes
   become relevant.
7. Audit implicit backend activation, input forcing, and derivation closure at
   capability boundaries; reuse established invariants rather than relitigating
   downstream symbol validity.

The key mental model is: this is not a file migration, a naming cleanup, or a
large rebase. It is the incremental extraction and landing of composable
capability vTables and their derived backends, proven through the real closure
of a machine.
