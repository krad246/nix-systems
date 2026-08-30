# Dendritic declarations

`dendritic.configurations` is a typed declaration tree. It describes evaluator
inputs—module contributions, users, hosts, and variants—and the evaluator
projects those declarations into `nixosConfigurations`, `darwinConfigurations`,
`homeConfigurations`, and `perSystem.packages`.

The declaration vocabulary has four separate concerns:

- `perClass` selects modules for an evaluator class.
- `perTag` names semantic profile aspects.
- `users` and `hosts` provide the configuration coordinates.
- `variants` add sparse deltas to an existing coordinate.

## Evaluator classes

`perClass` is the module-system class projection axis. Its class keys are:

```nix
perClass = {
  nixos.modules = [ ... ];
  darwin.modules = [ ... ];
  homeManager.modules = [ ... ];
};
```

`homeManager` is the Home Manager module-system class. The helper used by the
example can still accept a separate module origin, but the projection keys
remain the actual class names exposed by the upstream module interface.

Each class uses the same composition grammar. In addition to `modules`, a class
can contribute `specialArgs`, `extraSpecialArgs`, `lateModuleArgs`, `metadata`,
and per-user `users.<name>.modules`. These values are accumulated when the
corresponding evaluator is constructed.

`classes.<name>.nativeClass` is a host-to-module-class mapping, not another
module composition axis. For example:

```nix
classes.laptop.nativeClass = "darwin";
hosts.nixbook.class = "laptop";
```

Semantic profile composition belongs in tags, not in `perClass.laptop`.

## Profile tags

Every `tags` option has the same meaning: its values select ordered profile
aspects. Tag names are restricted to regular top-level files in
`inputs.dendritic/modules/profiles`; they are profile attributes, never host
names, application names, or low-level capabilities.

A tag reuses the evaluator-class grammar:

```nix
perTag.workstation = {
  perClass = {
    nixos.modules = [ ... ];
    darwin.modules = [ ... ];
    homeManager.modules = [ ... ];
  };

  # Descriptive facts and arbitrary data are passive passthrough channels.
  meta = { purpose = "daily workstation"; };
  passthru = { capability = "interactive"; };
};
```

Selecting `workstation` materializes only the modules for the evaluator being
constructed. `meta` and `passthru` do not select modules or alter options; they
are carried on normalized declaration metadata for downstream consumers. In
practice, `passthru` is the general-purpose channel.

Tags can be attached at the root, host, user, host-user, or variant node. The
same ordered tag list is interpreted consistently at each location. A variant's
tags extend its parent coordinate; they do not replace the parent's tags.

## Users

Users participate in host-derived Home Manager configurations when
`users.<name>.enable` is true:

```nix
users.krad246 = {
  enable = true;
  tags = [ "standalone" ];
  standalone = lib.mkIf (!lib.inPureEvalMode) {
    pkgs = withSystem builtins.currentSystem ({ pkgs, ... }: pkgs);
    modules = [ ... ];
  };
};
```

`standalone` is nullable. `null` means the user is hosted only; a non-null block
supplies the required package set and enables an independent
`homeConfigurations.<name>` output. There is no special user identity named
`standalone`, and no nested standalone enable flag.

Users may also declare sparse Home Manager `variants`. User variants use the
same additive module and tag contract as system variants.

## Hosts

A host declaration supplies its evaluator class, target platform, profile tags,
host modules, integrated users, and system variants:

```nix
hosts.nixbook = {
  enable = true;
  class = "laptop";
  hostPlatforms = [{ system = "aarch64-darwin"; }];
  tags = [ "workstation" ];
  modules = [ ... ];
  users.krad246 = {};
};
```

`class` resolves through `classes.<name>.nativeClass`; platform validation and
cross-build gating happen when the system coordinate is constructed. Host-local
`metadata` describes machine facts. It is separate from profile `meta` and
`passthru`.

## Variants

A variant is an additive module delta over its parent coordinate. The evaluator
constructs the parent once and applies that delta independently for each
projection:

- `enableFlakeOutput` publishes an independent configuration output.
- `includeSpecialisations` embeds the same delta in a NixOS specialisation set.
- `package` selects an artifact from the independently evaluated configuration.
- `outputName` overrides the generated sparse output name.
- `tags` adds ordered profile aspects to the variant.

These controls are independent. Nix module priorities provide override
semantics inside the variant; a variant is not a second host.

## Composition and outputs

For each host platform, the evaluator composes:

```text
shared → root tags → evaluator class → architecture → system → host tags → host
```

Integrated Home Manager users receive the corresponding `home` contributions
and user/host-user modules at the same coordinate. Standalone users are
projected separately. Package projections enumerate only enabled,
package-bearing variant coordinates and publish them under `perSystem.packages`.

The evaluator writes the native flake namespaces directly:

- `nixosConfigurations` for NixOS coordinates;
- `darwinConfigurations` for nix-darwin coordinates;
- `homeConfigurations` for standalone and host/user Home Manager coordinates;
- `perSystem.packages` for selected variant artifacts.
