{
  config,
  inputs,
  lib,
  ...
}: let
  projection = import ./configuration-projections.nix;

  nixos = projection {
    inherit lib;
    construct = _: declaration:
      inputs.nixpkgs.lib.nixosSystem {
        modules =
          [
            {nixpkgs.hostPlatform = declaration.system;}
          ]
          ++ lib.optional (declaration.cross && declaration.buildSystem != declaration.system) {
            nixpkgs.buildPlatform = declaration.buildSystem;
          }
          ++ declaration.modules;
      };
    embed = root: variants:
      root.extendModules {
        modules = [
          {
            specialisation =
              lib.mapAttrs (_: variant: {
                configuration.imports = variant.modules;
              })
              variants;
          }
        ];
      };
  };

  darwin = projection {
    inherit lib;
    construct = _: declaration:
      inputs.darwin.lib.darwinSystem {
        modules =
          [
            {nixpkgs.hostPlatform = declaration.system;}
          ]
          ++ lib.optional (declaration.cross && declaration.buildSystem != declaration.system) {
            nixpkgs.buildPlatform = declaration.buildSystem;
          }
          ++ declaration.modules;
      };
  };

  resolve = policy: declarations:
    lib.mapAttrs (_: declaration:
      declaration
      // {
        cross =
          if declaration.cross != null
          then declaration.cross
          else policy.cross;
        variants = lib.mapAttrs (_: variant:
          variant
          // {
            publish =
              if variant.publish != null
              then variant.publish
              else if declaration.publishVariants != null
              then declaration.publishVariants
              else policy.publish;
            embed =
              if variant.embed != null
              then variant.embed
              else if declaration.embedVariants != null
              then declaration.embedVariants
              else policy.embed;
          })
        declaration.variants;
      })
    declarations;

  selected = system: declarations:
    lib.mapAttrs (_: declaration: let
      buildSystem =
        if declaration.buildSystem == null
        then system
        else declaration.buildSystem;
    in
      if buildSystem != system && !declaration.cross
      then throw "dendritic.systems: ${system} requires cross.enable for build system ${buildSystem}"
      else declaration // {inherit system buildSystem;})
    (lib.filterAttrs (_: declaration: builtins.elem system declaration.systems) declarations);

  is = predicate: system:
    predicate (lib.systems.parse.mkSystemFromString system);

  outputs = system: declarations: let
    selectedDeclarations = selected system declarations;
    backend =
      if is lib.systems.inspect.predicates.isDarwin system
      then darwin
      else if is lib.systems.inspect.predicates.isLinux system
      then nixos
      else throw "dendritic.systems: unsupported target system ${system}";
  in
    backend.definitions null config.dendritic.systems.nameFunction selectedDeclarations;
in {
  imports = [inputs.darwin.flakeModules.default];

  options.dendritic.systems = {
    nameFunction = lib.mkOption {
      type = lib.types.functionTo (lib.types.functionTo lib.types.str);
      default = configuration: variant: "${configuration}-${variant}";
      description = "Function generating output names from a system declaration and variant.";
    };

    variants = {
      publish = lib.mkEnableOption "independently buildable system variant outputs by default";
      embed = lib.mkEnableOption "system variants in their parent specialisation tables by default";
    };

    cross = lib.mkEnableOption "cross-system system projections by default";

    configurations = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          systems = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Target platform systems; each selects an internal evaluator projection.";
          };
          buildSystem = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Build platform; null means the selected target system.";
          };
          cross = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = "Whether differing build and target systems are permitted.";
          };
          modules = lib.mkOption {
            type = lib.types.listOf lib.types.deferredModule;
            default = [];
            description = "Modules passed to the selected system evaluator.";
          };
          publishVariants = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = "Default publication policy for this declaration's variants.";
          };
          embedVariants = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = "Default embedding policy for this declaration's variants.";
          };
          variants = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                modules = lib.mkOption {
                  type = lib.types.listOf lib.types.deferredModule;
                  default = [];
                };
                publish = lib.mkOption {
                  type = lib.types.nullOr lib.types.bool;
                  default = null;
                };
                embed = lib.mkOption {
                  type = lib.types.nullOr lib.types.bool;
                  default = null;
                };
              };
            });
            default = {};
          };
        };
      });
      default = {};
      description = "Unified system declarations projected through internal system evaluators.";
    };
  };

  config = let
    declarations =
      resolve {
        publish = config.dendritic.systems.variants.publish;
        embed = config.dendritic.systems.variants.embed;
        cross = config.dendritic.systems.cross;
      }
      config.dendritic.systems.configurations;
    targetSystems = lib.unique (lib.concatMap (declaration: declaration.systems) (builtins.attrValues declarations));
    linuxSystems = lib.filter (system: is lib.systems.inspect.predicates.isLinux system) targetSystems;
    darwinSystems = lib.filter (system: is lib.systems.inspect.predicates.isDarwin system) targetSystems;
  in {
    dendritic.systems = {
      variants.publish = lib.mkDefault true;

      configurations.generic-headless-interactive = {
        systems = ["x86_64-linux"];
        modules = [
          config.flake.dendritic.modules.nixos.headless
          config.flake.dendritic.modules.nixos.interactive
          (_: {networking.hostName = "generic-headless-interactive";})
        ];
        variants = {
          dev.modules = [
            (_: {environment.etc."dendritic-variant".text = "dev";})
          ];
          vm-nogui = {
            modules = [
              ({config, ...}: {
                image.modules.vm = import ./image-modules/vm.nix;
                image.modules.vm-nogui = import ./image-modules/vm-nogui.nix {
                  vm = config.image.modules.vm;
                };
              })
            ];
            embed = true;
          };
        };
      };

      configurations.nixbook-pro-composed = {
        systems = ["aarch64-darwin"];
        modules = [
          config.flake.dendritic.modules.darwin.workstation
          config.flake.dendritic.modules.darwin.linux-builder
          config.flake.dendritic.modules.darwin.tailscale
          (_: {networking.hostName = "nixbook-pro-composed";})
        ];
      };
    };

    flake.nixosConfigurations = lib.mkMerge (lib.concatMap (system: outputs system declarations) linuxSystems);
    flake.darwinConfigurations = lib.mkMerge (lib.concatMap (system: outputs system declarations) darwinSystems);
  };
}
