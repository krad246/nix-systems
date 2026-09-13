{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  systemCoordinates = config.dendritic.internal.systemCoordinates;
  flakeSystems = lib.unique (lib.filter (system: system != "x86_64-darwin") config.systems);
  profileNames = config.dendritic.internal.profileNames;

  moduleClass = system:
    if lib.systems.inspect.predicates.isDarwin (lib.systems.parse.mkSystemFromString system)
    then "darwin"
    else if lib.systems.inspect.predicates.isLinux (lib.systems.parse.mkSystemFromString system)
    then "nixos"
    else throw "dendritic.configurations: unsupported host platform ${system}";

  variantUsesVirtualisation = variant:
    variant.virtualisation != null || lib.elem "virtualisation" variant.tags;

  virtualisationEnabled = variant:
    config.dendritic.virtualisation.enable
    && (
      if variant.virtualisation == null
      then lib.elem "virtualisation" variant.tags
      else variant.virtualisation.enable
    );

  profileSystemModules = evaluatorClass: tags:
    lib.concatMap (tag:
      if lib.elem tag profileNames
      then (config.dendritic.configurations.perTag.${tag}.perClass.${evaluatorClass} or {}).modules or []
      else [])
    tags;

  profileHomeModules = username: tags:
    lib.concatMap (tag:
      if lib.elem tag profileNames
      then let
        contribution = config.dendritic.configurations.perTag.${tag}.perClass.homeManager or {};
      in
        (contribution.modules or []) ++ (contribution.users.${username}.modules or [])
      else [])
    tags;

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

  validBuildSystems = normalized: let
    candidates =
      if normalized.buildPlatforms == null
      then flakeSystems
      else map (platform: platform.system) normalized.buildPlatforms;
  in
    lib.unique (lib.filter (buildSystem:
      buildSystem == normalized.hostPlatform.system || normalized.crossCompile)
    candidates);

  enabledVariants = normalized:
    lib.filterAttrs (_: variant:
      config.dendritic.configurations.defaults.variants.enableFlakeOutputs
      && config.dendritic.configurations.defaults.variants.enable
      && variant.enableFlakeOutput
      && variant.enable
      && (!variantUsesVirtualisation variant || virtualisationEnabled variant)
      && variant.package != null)
    normalized.declaration.variants;

  packageCoordinates = lib.concatMap (normalized: let
    variants = enabledVariants normalized;
    buildPlatforms = validBuildSystems normalized;
    preferredBuildPlatform =
      if lib.elem normalized.hostPlatform.system buildPlatforms
      then normalized.hostPlatform.system
      else builtins.head buildPlatforms;
    rows = runnerPlatform: buildPlatform: variants:
      lib.mapAttrsToList (variantName: variant: {
        inherit normalized buildPlatform runnerPlatform variantName variant;
      })
      variants;
  in
    (lib.concatMap (buildPlatform: rows buildPlatform buildPlatform variants) buildPlatforms)
    ++ (lib.concatMap (runnerPlatform:
      rows runnerPlatform preferredBuildPlatform (lib.filterAttrs (_: virtualisationEnabled) variants))
    (lib.filter (runnerPlatform: !lib.elem runnerPlatform buildPlatforms) flakeSystems)))
  config.dendritic.internal.systemCoordinates;

  variantModules = normalized: variantName: variant:
    [{_module.args = variant.lateModuleArgs;}]
    ++ profileSystemModules (moduleClass normalized.hostPlatform.system) variant.tags
    ++ virtualisationModules variantName variant
    ++ variant.modules
    ++ lib.mapAttrsToList (username: _: {
      home-manager.users.${username}.imports =
        profileHomeModules username variant.tags
        ++ (variant.users.${username}.modules or []);
    })
    normalized.users;

  baseConfiguration = coordinate:
    withSystem coordinate.buildPlatform (_: let
      constructor =
        if moduleClass coordinate.normalized.hostPlatform.system == "darwin"
        then inputs.darwin.lib.darwinSystem
        else if moduleClass coordinate.normalized.hostPlatform.system == "nixos"
        then inputs.nixpkgs.lib.nixosSystem
        else throw "dendritic.configurations: unsupported target system ${coordinate.normalized.hostPlatform.system}";
      nixpkgsPlatformModules = [
        {nixpkgs.buildPlatform = coordinate.buildPlatform;}
        {nixpkgs.hostPlatform = coordinate.normalized.hostPlatform.system;}
      ];
    in
      constructor {
        # Keep nixpkgs.pkgs unset: the native evaluator performs the normal
        # nixpkgs splice from these build/host platform options.
        specialArgs = coordinate.normalized.specialArgs;
        modules =
          nixpkgsPlatformModules
          ++ [
            {_module.args = coordinate.normalized.lateModuleArgs;}
          ]
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
          coordinate.normalized.users
          ++ coordinate.normalized.modules;
      });

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

  builderSupportModules = coordinate:
    lib.optional (virtualisationEnabled coordinate.variant)
    (withSystem coordinate.runnerPlatform ({pkgs, ...}:
      # The runner is a separate platform from the Linux guest. Preload its
      # package set into the capability interface so qemu-vm uses a native
      # runner (including Darwin) while the target system remains Linux.
      {virtualisation.host.pkgs = pkgs;}));

  selectedPackages = buildSystem:
    lib.concatMap (coordinate: let
      root = baseConfiguration coordinate;
      variantConfiguration =
        if variantModules coordinate.normalized coordinate.variantName coordinate.variant == []
        then root
        else
          root.extendModules {
            specialArgs = lib.mergeAttrsList [coordinate.variant.specialArgs coordinate.variant.extraSpecialArgs];
            modules =
              (builderSupportModules coordinate)
              ++ variantModules coordinate.normalized coordinate.variantName coordinate.variant;
          };
    in
      lib.optional (coordinate.runnerPlatform == buildSystem) {
        "${variantOutputName coordinate.normalized coordinate.variantName coordinate.variant}" =
          coordinate.variant.package variantConfiguration;
      })
    packageCoordinates;
in {
  perSystem = {system, ...}: {
    packages = lib.mkMerge (selectedPackages system);
  };
}
