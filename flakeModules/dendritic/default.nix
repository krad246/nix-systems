{
  inputs,
  lib,
  ...
}: let
  importWithTypes = path: let
    argumentOption = description:
      lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = {};
        inherit description;
      };

    platformType = lib.types.submodule {
      options.system = lib.mkOption {
        type = lib.types.str;
        description = "A platform constraint identified by its system string.";
      };
    };

    crossCompilation = lib.modules.importApply ./cross-compilation.nix {inherit lib;};

    moduleContributions = {
      imports = [crossCompilation];
      options = {
        modules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [];
          description = "Modules contributed in the parent evaluator context.";
        };
        specialArgs = argumentOption "Early module arguments passed to the native system evaluator.";
        extraSpecialArgs = argumentOption "Additional arguments passed to Home Manager modules.";
        lateModuleArgs = argumentOption "Late module arguments contributed through _module.args.";
        metadata = lib.mkOption {
          type = lib.types.attrsOf lib.types.raw;
          default = {};
          description = "Declarative data carried by this composition for downstream projections.";
        };
      };
    };

    composition = {
      imports = [moduleContributions];
      options.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule moduleContributions);
        default = {};
        description = "Home Manager module contributions for users selected by a host.";
      };
    };

    variant = {
      imports = [composition];
      options = {
        tags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Ordered profile aspects selecting additional contributions for this variant node.";
        };
        enableFlakeOutput = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to materialize this variant as an independent flake output and artifact coordinate.";
        };
        outputName = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Optional name for this independently materialized variant node.";
        };
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Compatibility gate for this variant; prefer enableFlakeOutput for new declarations.";
        };
        includeSpecialisations = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "Whether to include this variant in its parent's specialisation set; null inherits the global default.";
        };
        package = lib.mkOption {
          type = lib.types.nullOr (lib.types.functionTo lib.types.package);
          default = null;
          description = "Optional target-specific selector returning a package from this independently evaluated variant configuration.";
        };
        virtualisation = lib.mkOption {
          type = lib.types.nullOr (lib.types.submodule {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Enable the framework virtualization capability for this variant.";
              };
              options = lib.mkOption {
                type = lib.types.attrsOf lib.types.raw;
                default = {};
                description = "Direct NixOS virtualization options merged after the selected default preset.";
              };
              modules = lib.mkOption {
                type = lib.types.listOf lib.types.deferredModule;
                default = [];
                description = "Additional modules merged after the selected default preset.";
              };
            };
          });
          default = null;
          description = "Optional virtualization capability declaration; the variant name selects its default preset.";
        };
      };
    };

    virtualisation = {
      options.modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = "NixOS modules forming one virtualization preset.";
      };
    };

    hostUsers = {
      options.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          imports = [moduleContributions];
          options = {
            tags = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "Ordered profile aspects selecting contributions for this user within one host.";
            };
            outputName = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Optional name for this user's Home Manager projection on its host.";
            };
          };
        });
        default = {};
        description = "Host-specific module contributions for integrated Home Manager users.";
      };
    };

    types = {
      inherit argumentOption platformType moduleContributions composition hostUsers;
      compositionType = lib.types.submodule composition;
      variantType = lib.types.submodule variant;
      virtualisationPresetType = lib.types.submodule virtualisation;
    };
  in
    lib.modules.importApply path {
      inherit inputs lib types;
    };
in {
  imports = [
    ./flake-module.nix
    (importWithTypes ./profiles.nix)
    (importWithTypes ./hosts.nix)
    (importWithTypes ./users.nix)
    ./capabilities.nix
    (importWithTypes ./virtualisation.nix)
    ./bridge.nix
    ./profile-layers.nix
    ./host-declarations.nix
    ./system-coordinates.nix
    ./system-outputs.nix
    ./home-manager-outputs.nix
    ./package-projections.nix
    ./configurations.nix
  ];
}
