# Dendritic declarations

`dendritic.configurations` is a typed declaration tree. Hosts, users, and
variants are named nodes; generated outputs derive their names from those nodes
and can be overridden at the node that owns them.

## Tags

Every `tags` option has the same meaning: its values select an ordered profile
aspect. Tag names are restricted to the regular top-level files in the
canonical `inputs.dendritic/modules/profiles` directory (for example `base`,
`desktop`, `dev`, `headless`, `standalone`, and `workstation`). They are profile
attributes, never host names, application names, or low-level capabilities.

Selecting a tag materializes the corresponding profile modules for the target
platform and Home Manager node. `perTag.<name>.perClass` reuses the same
class-composition grammar as the top-level `perClass`: use
`perClass.<class>.modules`, with `home` as the Home Manager evaluator class. The
module origin may still be named `homeManager`; the projection contract is
deliberately independent. This keeps the tag key as the aspect interface while
making platform selection explicit.
`users.<name>.modules` adds a user-specific Home Manager contribution, while
`meta` carries descriptive profile facts and `passthru` carries arbitrary data
to downstream projections; both are preserved on normalized declaration rows.
The same rule applies at
root, host, user, host-user, and variant nodes.

## Variants

A variant is an additive module delta over its parent coordinate. The evaluator
constructs the parent once and applies that exact delta for each projection:

- `enableFlakeOutput = true` publishes an independently evaluated configuration; an
  optional `package` then selects an image or other artifact from it.
- `includeSpecialisations = true` embeds the same delta in a NixOS native
  specialisation set.
- `tags` adds ordered profile aspects and their `perTag` overlays after the
  parent composition.

These are independent controls. Nix module priorities inside the variant are
the override mechanism; a variant is not a second host.

## Composition order

For each host platform, Dendritic composes:

`shared → root tags → native/semantic class → architecture → system → host tags → host`.

The same sequence is preserved when a system variant or its package projection
is materialized. Class aliases are declared under `classes.<name>.nativeClass`;
they use the native NixOS or nix-darwin evaluator while retaining their own
`perClass.<name>` contribution set.
