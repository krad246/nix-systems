{
  config,
  inputs,
  lib,
  ...
}: let
  projection = import ./configuration-projections.nix;

  userModules = declaration:
    lib.mapAttrsToList (username: user: {
      home-manager.users.${username}.imports = user.modules;
    })
    declaration.users;

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
          ++ userModules declaration
          ++ declaration.modules;
      };
    includeSpecialisation = root: variants:
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
          ++ userModules declaration
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
              else if declaration.publish != null
              then declaration.publish
              else policy.publish;
            includeSpecialisation =
              if variant.includeSpecialisation != null
              then variant.includeSpecialisation
              else if declaration.includeSpecialisation != null
              then declaration.includeSpecialisation
              else policy.includeSpecialisation;
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
    backend.definitions null config.dendritic.systems.outputs.nameFunction selectedDeclarations;

  imageOutputs = buildSystem: declarations: let
    candidates = lib.concatMap (rootName: let
      declaration = declarations.${rootName};
      targetSystems = lib.filter (target: let
        configuredBuild =
          if declaration.buildSystem == null
          then target
          else declaration.buildSystem;
      in
        configuredBuild == buildSystem)
      declaration.systems;
    in
      lib.concatMap (target: let
        selectedDeclaration = (selected target declarations).${rootName};
        backend =
          if is lib.systems.inspect.predicates.isDarwin target
          then darwin
          else if is lib.systems.inspect.predicates.isLinux target
          then nixos
          else throw "dendritic.systems: unsupported image target system ${target}";
        root = backend.configuration null selectedDeclaration;
      in
        lib.mapAttrsToList (imageName: image: let
          projection =
            if image.modules == []
            then root
            else root.extendModules {inherit (image) modules;};
          value = lib.getAttrFromPath ["system" "build" "images" imageName] projection.config;
        in {${config.dendritic.systems.outputs.imageNameFunction rootName target imageName} = value;})
        declaration.images)
      targetSystems) (builtins.attrNames declarations);
  in
    lib.mkMerge candidates;
in {
  imports = [inputs.darwin.flakeModules.default];

  options.dendritic.systems = {
    outputs = {
      nameFunction = lib.mkOption {
        type = lib.types.functionTo (lib.types.functionTo lib.types.str);
        default = configuration: variant: "${configuration}-${variant}";
        description = "Function generating output names from a system declaration and variant.";
      };

      imageNameFunction = lib.mkOption {
        type = lib.types.functionTo (lib.types.functionTo (lib.types.functionTo lib.types.str));
        default = root: system: image: "${root}-${image}-${system}";
        defaultText = lib.literalExpression ''root: system: image: "''${root}-''${image}-''${system}"'';
        description = "Function generating package names from a root, target system, and image.";
      };
    };

    variants = {
      publish = lib.mkEnableOption "independently buildable system variant outputs by default";
      includeSpecialisation = lib.mkEnableOption "system variants in their parent specialisation tables by default";
    };

    cross = lib.mkEnableOption "cross-system system projections by default";

    configurations = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          systems = lib.mkOption {
            type = lib.types.nonEmptyListOf lib.types.str;
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
          users = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options.modules = lib.mkOption {
                type = lib.types.listOf lib.types.deferredModule;
                default = [];
                description = "Home Manager modules for this integrated system user.";
              };
            });
            default = {};
            description = "Named Home Manager users projected into the system evaluator.";
          };
          publish = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = "Default publication policy for this declaration's variants.";
          };
          includeSpecialisation = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = "Default inclusion policy for this declaration's variants.";
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
                includeSpecialisation = lib.mkOption {
                  type = lib.types.nullOr lib.types.bool;
                  default = null;
                };
              };
            });
            default = {};
          };
          images = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                modules = lib.mkOption {
                  type = lib.types.listOf lib.types.deferredModule;
                  default = [];
                  description = "Modules applied while materializing this image.";
                };
              };
            });
            default = {};
            description = "Named image projections of this declaration's systems.";
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
        includeSpecialisation = config.dendritic.systems.variants.includeSpecialisation;
        cross = config.dendritic.systems.cross;
      }
      config.dendritic.systems.configurations;
    # Union target systems as attribute keys so duplicate declarations merge naturally.
    targetSystems = lib.pipe declarations [
      builtins.attrValues
      (lib.foldl' (systems: declaration: systems // lib.genAttrs declaration.systems (_: true)) {})
      builtins.attrNames
    ];
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
            includeSpecialisation = true;
          };
        };
        images.vm-nogui = {
          modules = [
            ({config, ...}: {
              image.modules.vm = import ./image-modules/vm.nix;
              image.modules.vm-nogui = import ./image-modules/vm-nogui.nix {
                vm = config.image.modules.vm;
              };
            })
          ];
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
        users.krad246.modules = [
          {home.sessionVariables.DENDRITIC_SYSTEM_USER = "true";}
        ];
      };
    };

    flake.nixosConfigurations = lib.mkMerge (lib.concatMap (system: outputs system declarations) linuxSystems);
    flake.darwinConfigurations = lib.mkMerge (lib.concatMap (system: outputs system declarations) darwinSystems);

    perSystem = {system, ...}: {
      packages = imageOutputs system declarations;
    };
  };
}
