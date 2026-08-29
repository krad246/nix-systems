# Dendritic declarations

`dendritic.configurations` is a typed declaration tree. Hosts, users, and
variants are named nodes; generated outputs derive their names from those nodes
and can be overridden at the node that owns them.

## Tags

Every `tags` option has the same meaning: its values select `perTag.<name>` in
the order written. Root tags apply to every host root and standalone Home
Manager root. Host tags refine that root. User and host-user tags refine their
Home Manager node. Variant tags are the final additive layers of a variant.

`perTag` is a mergeable declaration layer. Its `modules` are for the enclosing
system evaluator, `homeModules` are for standalone Home Manager roots, and
`users.<name>.modules` are for a selected integrated Home Manager user. Its
`metadata` is carried on normalized declaration rows for downstream projections.

## Variants

A variant is an additive module delta over its parent coordinate. The evaluator
constructs the parent once and applies that exact delta for each projection:

- `build = true` publishes an independently evaluated configuration; an
  optional `package` then selects an image or other artifact from it.
- `includeSpecialisations = true` embeds the same delta in a NixOS native
  specialisation set.
- `tags` adds ordered `perTag` variant layers after the parent composition.

These are independent controls. Nix module priorities inside the variant are
the override mechanism; a variant is not a second host.

## Layer order

For each host platform, Dendritic composes:

`shared → root tags → native/semantic class → architecture → system → host tags → host`.

The same sequence is preserved when a system variant or its package projection
is materialized. Class aliases are declared under `classes.<name>.nativeClass`;
they use the native NixOS or nix-darwin evaluator while retaining their own
`perClass.<name>` layer.
