{types, ...}: {
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  inherit (types) hostUsers moduleContributions platformType profileTagType variantType;
  configurations = config.dendritic.configurations;
  profileNames = config.dendritic.internal.profileNames;
  systemCoordinates = resolvedSystemCoordinates;

  mergeArgs = field: contributions:
    lib.mergeAttrsList (map (contribution: contribution.${field} or {}) contributions);

  moduleClass = platforms: let
    systems = map (platform: lib.systems.parse.mkSystemFromString platform.system) platforms;
  in
    if systems == []
    then throw "dendritic.configurations: an enabled host must declare at least one host platform"
    else if lib.all lib.systems.inspect.predicates.isDarwin systems
    then "darwin"
    else if lib.all lib.systems.inspect.predicates.isLinux systems
    then "nixos"
    else throw "dendritic.configurations: host platforms must be Linux or Darwin";

  profileSystemModules = evaluatorClass: tags:
    lib.concatMap (tag:
      if lib.elem tag profileNames
      then (configurations.perTag.${tag}.perClass.${evaluatorClass} or {}).modules or []
      else [])
    tags;

  profileHomeModules = username: tags:
    lib.concatMap (tag:
      if lib.elem tag profileNames
      then let
        contribution = configurations.perTag.${tag}.perClass.homeManager or {};
      in
        (contribution.modules or []) ++ (contribution.users.${username}.modules or [])
      else [])
    tags;

  profileContribution = tag:
    if lib.elem tag profileNames
    then configurations.perTag.${tag}
    else {};

  resolvedSystemDeclarations = lib.pipe configurations.hosts [
    (lib.filterAttrs (_: host: host.enable))
    (lib.mapAttrs (hostName: host: let
      evaluatorClass = moduleClass host.hostPlatforms;
      baseContributions = [configurations.shared];
      rootTagContributions = map (tag: (profileContribution tag).perClass.${evaluatorClass} or {}) configurations.defaults.tags;
      hostTagContributions = map (tag: (profileContribution tag).perClass.${evaluatorClass} or {}) host.tags;
      rootHomeTagContributions = map (tag: (profileContribution tag).perClass.homeManager or {}) configurations.defaults.tags;
      hostHomeTagContributions = map (tag: (profileContribution tag).perClass.homeManager or {}) host.tags;
      systemContributions = baseContributions ++ rootTagContributions ++ hostTagContributions ++ [host];
      baseModules =
        configurations.shared.modules
        ++ profileSystemModules evaluatorClass configurations.defaults.tags;
      tagModules = profileSystemModules evaluatorClass host.tags;
      selectedUsers =
        lib.filterAttrs (
          username: _: configurations.users ? ${username} && configurations.users.${username}.enable
        )
        host.users;
    in {
      inherit (host) enable outputName hostPlatforms buildPlatforms crossCompile variants;
      tags = configurations.defaults.tags ++ host.tags;
      inherit baseModules tagModules;
      hostModules = host.modules;
      modules = baseModules ++ tagModules ++ host.modules;
      specialArgs = lib.mergeAttrsList [
        configurations.globalArgs
        configurations.earlyModuleArgs
        (mergeArgs "specialArgs" systemContributions)
      ];
      lateModuleArgs = lib.mergeAttrsList [
        configurations.lateModuleArgs
        (mergeArgs "lateModuleArgs" systemContributions)
      ];
      users =
        lib.mapAttrs (username: hostLayer: let
          user = configurations.users.${username};
          userContributions =
            [configurations.shared]
            ++ rootHomeTagContributions
            ++ map (tag: configurations.perTag.${tag}.perClass.homeManager or {}) user.tags
            ++ hostHomeTagContributions
            ++ map (tag: configurations.perTag.${tag}.perClass.homeManager or {}) hostLayer.tags
            ++ [user hostLayer];
          baseUserModules =
            user.modules
            ++ profileHomeModules username configurations.defaults.tags
            ++ profileHomeModules username user.tags;
          taggedUserModules =
            profileHomeModules username host.tags
            ++ profileHomeModules username hostLayer.tags;
        in {
          inherit (hostLayer) outputName;
          tags = user.tags ++ hostLayer.tags;
          baseModules = baseUserModules;
          tagModules = taggedUserModules;
          hostModules = hostLayer.modules;
          modules = baseUserModules ++ taggedUserModules ++ hostLayer.modules;
          extraSpecialArgs = lib.mergeAttrsList [
            configurations.globalArgs
            (mergeArgs "specialArgs" userContributions)
            (mergeArgs "extraSpecialArgs" userContributions)
          ];
          specialArgs = lib.mergeAttrsList [
            configurations.globalArgs
            configurations.earlyModuleArgs
            (mergeArgs "specialArgs" userContributions)
          ];
          lateModuleArgs = lib.mergeAttrsList [
            configurations.lateModuleArgs
            (mergeArgs "lateModuleArgs" userContributions)
          ];
        })
        selectedUsers;
      metadata = {
        inherit hostName;
        tags = map (tag: {
          name = tag;
          meta = configurations.perTag.${tag}.meta or {};
          passthru = configurations.perTag.${tag}.passthru or {};
        }) (configurations.defaults.tags ++ host.tags);
        host = host.metadata;
      };
    }))
  ];

  resolvedSystemCoordinates = lib.concatLists (lib.mapAttrsToList (hostName: declaration:
    map (hostPlatform: let
      arch = builtins.head (lib.splitString "-" hostPlatform.system);
      archLayer = configurations.perArch.${arch} or {};
      systemLayer = configurations.perSystem.${hostPlatform.system} or {};
      coordinate = {
        inherit hostName hostPlatform declaration;
        inherit (declaration) outputName buildPlatforms crossCompile variants;
        specialArgs = lib.mergeAttrsList [
          declaration.specialArgs
          (archLayer.specialArgs or {})
          (systemLayer.specialArgs or {})
        ];
        lateModuleArgs = lib.mergeAttrsList [
          declaration.lateModuleArgs
          (archLayer.lateModuleArgs or {})
          (systemLayer.lateModuleArgs or {})
        ];
        modules =
          declaration.baseModules
          ++ (archLayer.modules or [])
          ++ (systemLayer.modules or [])
          ++ declaration.tagModules
          ++ declaration.hostModules;
        users =
          lib.mapAttrs (username: user: {
            inherit (user) tags;
            extraSpecialArgs = lib.mergeAttrsList [
              user.extraSpecialArgs
              (archLayer.extraSpecialArgs or {})
              (archLayer.users.${username}.extraSpecialArgs or {})
              (systemLayer.extraSpecialArgs or {})
              (systemLayer.users.${username}.extraSpecialArgs or {})
            ];
            lateModuleArgs = lib.mergeAttrsList [
              user.lateModuleArgs
              (archLayer.lateModuleArgs or {})
              (archLayer.users.${username}.lateModuleArgs or {})
              (systemLayer.lateModuleArgs or {})
              (systemLayer.users.${username}.lateModuleArgs or {})
            ];
            modules =
              user.baseModules
              ++ (archLayer.users.${username}.modules or [])
              ++ (systemLayer.users.${username}.modules or [])
              ++ user.tagModules
              ++ user.hostModules;
          })
          declaration.users;
        metadata = {
          declaration = declaration.metadata;
          platform = {
            inherit arch;
            inherit (hostPlatform) system;
            architecture = archLayer.metadata or {};
            systemLayer = systemLayer.metadata or {};
          };
        };
      };
    in
      coordinate)
    declaration.hostPlatforms)
  resolvedSystemDeclarations);

  variantUsesVirtualisation = variant:
    variant.virtualisation != null || lib.elem "virtualisation" variant.tags;

  virtualisationEnabled = variant:
    config.dendritic.virtualisation.enable
    && (
      if variant.virtualisation == null
      then lib.elem "virtualisation" variant.tags
      else variant.virtualisation.enable
    );

  virtualisationModules = variantName: variant: let
    cfg = variant.virtualisation;
    presetName =
      if config.dendritic.virtualisation.presets ? ${variantName}
      then variantName
      else "vm";
    preset = config.dendritic.virtualisation.presets.${presetName} or (throw "dendritic.virtualisation: unknown preset ${presetName}");
  in
    lib.optionals (virtualisationEnabled variant)
    (preset.modules
      ++ lib.optional (cfg != null && cfg.options != {}) cfg.options
      ++ (
        if cfg == null
        then []
        else cfg.modules
      ));

  profileSystemModulesFor = system: tags:
    profileSystemModules (moduleClass [{inherit system;}]) tags;

  hostOutputName = coordinate:
    if lib.count (candidate: candidate.hostName == coordinate.hostName) systemCoordinates == 1
    then
      if coordinate.outputName == null
      then coordinate.hostName
      else coordinate.outputName
    else "${
      if coordinate.outputName == null
      then coordinate.hostName
      else coordinate.outputName
    }-${coordinate.hostPlatform.system}";

  variantOutputName = coordinate: variantName: variant:
    if variant.outputName == null
    then "${hostOutputName coordinate}-${variantName}"
    else variant.outputName;

  variantModules = coordinate: variantName: variant:
    [{_module.args = variant.lateModuleArgs;}]
    ++ profileSystemModulesFor coordinate.hostPlatform.system variant.tags
    ++ virtualisationModules variantName variant
    ++ variant.modules
    ++ lib.optional (coordinate.users != {}) {
      home-manager.extraSpecialArgs = lib.mergeAttrsList (
        [variant.extraSpecialArgs]
        ++ lib.mapAttrsToList (username: user:
          lib.mergeAttrsList [
            user.extraSpecialArgs
            (variant.users.${username}.extraSpecialArgs or {})
          ])
        coordinate.users
      );
    }
    ++ lib.mapAttrsToList (username: _: {
      home-manager.users.${username}.imports =
        profileHomeModules username variant.tags
        ++ (variant.users.${username}.modules or []);
    })
    coordinate.users;

  baseConfiguration = coordinate:
    withSystem coordinate.hostPlatform.system ({pkgs, ...}: let
      constructor =
        if pkgs.stdenv.hostPlatform.isDarwin
        then inputs.darwin.lib.darwinSystem
        else if pkgs.stdenv.hostPlatform.isLinux
        then inputs.nixpkgs.lib.nixosSystem
        else throw "dendritic.configurations: unsupported target system ${pkgs.stdenv.hostPlatform.system}";
      nixpkgsPlatformModules = [
        {nixpkgs.buildPlatform = coordinate.hostPlatform.system;}
        {nixpkgs.hostPlatform = coordinate.hostPlatform.system;}
      ];
    in
      constructor {
        inherit (coordinate) specialArgs;
        modules =
          nixpkgsPlatformModules
          ++ [{_module.args = coordinate.lateModuleArgs;}]
          ++ lib.mapAttrsToList (username: user: {
            home-manager.users.${username} = {pkgs, ...}: {
              imports = user.modules;
              home.username = lib.mkDefault username;
              home.homeDirectory = lib.mkDefault (
                if pkgs.stdenv.hostPlatform.isDarwin
                then "/Users/${username}"
                else "/home/${username}"
              );
            };
          })
          coordinate.users
          ++ lib.optional (coordinate.users != {}) {
            home-manager.extraSpecialArgs = lib.mergeAttrsList (lib.mapAttrsToList (_: user: user.extraSpecialArgs) coordinate.users);
          }
          ++ coordinate.modules;
      });

  configuration = coordinate: let
    root = baseConfiguration coordinate;
    includedSpecialisations = lib.filterAttrs (_: variant:
      (!variantUsesVirtualisation variant || virtualisationEnabled variant)
      && (
        if variant.includeSpecialisations != null
        then variant.includeSpecialisations
        else configurations.defaults.variants.includeSpecialisations
      ))
    coordinate.variants;
  in
    if includedSpecialisations == {}
    then root
    else if moduleClass [{system = coordinate.hostPlatform.system;}] == "darwin"
    then throw "nix-darwin configurations do not support included specialisations"
    else
      root.extendModules {
        modules = [
          {
            specialisation =
              lib.mapAttrs (variantName: variant: {
                configuration.imports = variantModules coordinate variantName variant;
              })
              includedSpecialisations;
          }
        ];
      };

  outputRows = coordinate:
    [{${hostOutputName coordinate} = configuration coordinate;}]
    ++ lib.mapAttrsToList (variantName: variant: {
      ${variantOutputName coordinate variantName variant} = (baseConfiguration coordinate).extendModules {
        inherit (variant) specialArgs;
        modules = variantModules coordinate variantName variant;
      };
    }) (lib.filterAttrs (_: variant:
      configurations.defaults.variants.enableFlakeOutputs
      && configurations.defaults.variants.enable
      && variant.enableFlakeOutput
      && variant.enable
      && (!variantUsesVirtualisation variant || virtualisationEnabled variant))
    coordinate.variants);
in {
  options = {
    dendritic = {
      internal = {
        systemDeclarations = lib.mkOption {
          type = lib.types.attrsOf lib.types.raw;
          readOnly = true;
          internal = true;
        };
        systemCoordinates = lib.mkOption {
          type = lib.types.listOf lib.types.raw;
          readOnly = true;
          internal = true;
        };
      };
      configurations = {
        hosts = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            imports = [moduleContributions (hostUsers config)];
            options = {
              enable = lib.mkEnableOption "this NixOS or nix-darwin host";
              outputName = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Optional name for this host's root system output.";
              };
              tags = lib.mkOption {
                type = lib.types.listOf (profileTagType config);
                default = [];
                description = "Ordered profile aspects selecting the corresponding perTag.<name> overlays.";
              };
              metadata = lib.mkOption {
                type = lib.types.attrsOf lib.types.raw;
                default = {};
                description = "Machine facts and annotations carried with this host declaration.";
              };
              hostPlatforms = lib.mkOption {
                type = lib.types.listOf platformType;
                default = [];
                description = "Constraints describing every realizable destination host platform.";
              };
              variants = lib.mkOption {
                type = lib.types.attrsOf (variantType config);
                default = {};
                description = "Sparse system variant and specialisation coordinates.";
              };
            };
          });
          default = {};
          description = "System hosts forming one axis of the configuration matrix.";
        };
      };
    };
  };

  config = {
    dendritic.internal.systemDeclarations = resolvedSystemDeclarations;
    dendritic.internal.systemCoordinates = resolvedSystemCoordinates;

    flake = {
      nixosConfigurations = lib.mkMerge (lib.concatMap outputRows (lib.filter (coordinate: moduleClass [{system = coordinate.hostPlatform.system;}] == "nixos") systemCoordinates));
      darwinConfigurations = lib.mkMerge (lib.concatMap outputRows (lib.filter (coordinate: moduleClass [{system = coordinate.hostPlatform.system;}] == "darwin") systemCoordinates));
    };
  };
}
