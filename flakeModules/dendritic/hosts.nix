{
  config,
  inputs,
  lib,
  ...
}: let
  # Shared shape for a backend's per-configuration submodule: the module
  # list an evaluator needs, plus the same variant/specialisation vocabulary
  # `dendritic.homeManager` already proved. `supportsSpecialisation` lets a
  # backend without a native `specialisation` option (nix-darwin) still
  # expose the identical `includeSpecialisation` field on every variant -
  # the virtual interface is uniform across backends - while failing loudly
  # through that backend's own `assertions` if a caller tries to actually
  # turn it on, instead of silently doing nothing or omitting the option.
  mkConfigurationsOption = {
    supportsSpecialisation,
    description,
  }:
    lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
        options = {
          modules = lib.mkOption {
            type = lib.types.listOf lib.types.deferredModule;
            default = [];
            description = "Modules passed to the backend's evaluator.";
          };

          includeSpecialisations = lib.mkEnableOption "embedding this configuration's variants as specialisations in its own activation generation";

          variants = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                modules = lib.mkOption {
                  type = lib.types.listOf lib.types.deferredModule;
                  default = [];
                  description = "Module deltas for this variant.";
                };

                includeSpecialisation = lib.mkOption {
                  type = lib.types.bool;
                  default = config.includeSpecialisations;
                  defaultText = lib.literalExpression "the configuration's includeSpecialisations";
                  description =
                    if supportsSpecialisation
                    then "Whether this variant is embedded as a specialisation in the parent configuration's activation generation."
                    else "Unsupported by this backend; must remain false.";
                };
              };
            });
            default = {};
            description = "Named module deltas derived from this configuration.";
          };
        };
      }));
      default = {};
      inherit description;
    };

  # One candidate {name; value;} entry per root and per declared variant.
  # Kept as a flat list - no wrapper keys, no null sentinels - since the only
  # consumer that must validate name uniqueness is the real
  # `flake.<x>Configurations` option each backend declares, which this list
  # feeds straight through `lib.mkMerge`; the module system's own "defined
  # multiple times" error is the collision check, not a hand-rolled one.
  # Uniqueness is a property of `declarations`/`nameFunction` alone, so a
  # per-system consumer can reuse the same list without re-deriving that
  # proof.
  mkConfigurationEntries = {
    declarations,
    nameFunction,
    evaluate, # modules: -> evaluated root
    supportsSpecialisation,
    specialisationAssertions, # variant: -> [{assertion; message;}]
  }:
    lib.pipe declarations [
      (lib.mapAttrsToList (
        rootName: declaration: let
          root = evaluate declaration.modules;
          # Each variant's specialisation entry is individually `mkIf`-gated
          # on its own `includeSpecialisation`, so the module system decides
          # whether that entry is defined at all; an excluded variant does
          # not pay for the backend's specialisation bundling. A backend
          # lacking a native `specialisation` option at all (nix-darwin) must
          # not have that key set here - setting it, even to `{}`, is a hard
          # "option does not exist" eval error there, not a gate. Such a
          # backend still receives `assertions` so a variant that actually
          # requested embedding fails loudly rather than being silently
          # absorbed.
          rootWithSpecialisations = root.extendModules {
            modules = [
              (
                {assertions = lib.concatMap specialisationAssertions (builtins.attrValues declaration.variants);}
                // lib.optionalAttrs supportsSpecialisation {
                  specialisation = lib.mapAttrs (_: variant:
                    lib.mkIf variant.includeSpecialisation {
                      configuration.imports = variant.modules;
                    })
                  declaration.variants;
                }
              )
            ];
          };
        in
          # The root, with any opted-in variants embedded as specialisations.
          [(lib.nameValuePair rootName rootWithSpecialisations)]
          # Every declared variant is always reachable as its own
          # lightweight configuration - a genuine `extendModules` result -
          # regardless of whether the root embeds it as a specialisation.
          ++ lib.mapAttrsToList (
            variantName: variant:
              lib.nameValuePair (nameFunction rootName variantName) (
                root.extendModules {inherit (variant) modules;}
              )
          )
          declaration.variants
      ))
      lib.concatLists
    ];

  mkNameFunctionOption = lib.mkOption {
    type = lib.types.functionTo (lib.types.functionTo lib.types.str);
    # TODO(dendritic): Workshop the public root/variant naming vocabulary; shared with dendritic.homeManager.
    default = configuration: variant: "${configuration}-${variant}";
    defaultText = lib.literalExpression ''configuration: variant: "''${configuration}-''${variant}"'';
    description = "Function generating a flake output name from configuration and variant names.";
  };
in {
  imports = [inputs.darwin.flakeModules.default];

  options.dendritic.hosts = {
    nixos = {
      nameFunction = mkNameFunctionOption;
      configurations = mkConfigurationsOption {
        supportsSpecialisation = true;
        description = "NixOS host configuration declarations.";
      };
    };

    darwin = {
      nameFunction = mkNameFunctionOption;
      configurations = mkConfigurationsOption {
        supportsSpecialisation = false;
        description = "Darwin host configuration declarations.";
      };
    };
  };

  config = {
    flake.nixosConfigurations = lib.mkMerge (
      map (entry: {${entry.name} = entry.value;}) (
        mkConfigurationEntries {
          declarations = config.dendritic.hosts.nixos.configurations;
          nameFunction = config.dendritic.hosts.nixos.nameFunction;
          evaluate = modules: inputs.nixpkgs.lib.nixosSystem {inherit modules;};
          supportsSpecialisation = true;
          # NixOS supports specialisation natively; nothing to forbid.
          specialisationAssertions = _variant: [];
        }
      )
    );

    flake.darwinConfigurations = lib.mkMerge (
      map (entry: {${entry.name} = entry.value;}) (
        mkConfigurationEntries {
          declarations = config.dendritic.hosts.darwin.configurations;
          nameFunction = config.dendritic.hosts.darwin.nameFunction;
          evaluate = modules: inputs.darwin.lib.darwinSystem {inherit modules;};
          supportsSpecialisation = false;
          # nix-darwin has no native `specialisation` option; a variant that
          # requested embedding fails loudly through the config's own
          # `assertions` rather than silently doing nothing.
          specialisationAssertions = variant: [
            {
              assertion = !variant.includeSpecialisation;
              message = "specialisation embedding is not supported by nix-darwin";
            }
          ];
        }
      )
    );
  };
}
