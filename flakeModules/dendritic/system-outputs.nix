{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  systemCoordinates = config.dendritic.internal.systemCoordinates;
  profileNames = config.dendritic.internal.profileNames;
  capabilityTags = config.dendritic.internal.capabilityTags;

  virtualisationEnabled = variant:
    config.dendritic.virtualisation.enable
    && (
      if variant.virtualisation == null
      then lib.elem "virtualisation" variant.tags
      else variant.virtualisation.enable
    );

  profileSystemModules = nativeClass: tags:
    lib.concatMap (tag:
      if lib.elem tag profileNames
      then (config.dendritic.configurations.perTag.${tag}.perClass.${nativeClass} or {}).modules or []
      else assert lib.assertMsg (lib.elem tag capabilityTags) "dendritic.configurations: tag ${tag} is not a canonical profile aspect or framework capability"; [])
    tags;

  profileHomeModules = username: tags:
    lib.concatMap (tag:
      if lib.elem tag profileNames
      then let
        contribution = config.dendritic.configurations.perTag.${tag}.perClass.homeManager or {};
      in
        (contribution.modules or []) ++ (contribution.users.${username}.modules or [])
      else assert lib.assertMsg (lib.elem tag capabilityTags) "dendritic.configurations: tag ${tag} is not a canonical profile aspect or framework capability"; [])
    tags;

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
    [
      {_module.args = variant.lateModuleArgs;}
    ]
    ++ profileSystemModules coordinate.nativeClass variant.tags
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
    withSystem coordinate.hostPlatform.system (_: let
      constructor =
        if coordinate.nativeClass == "darwin"
        then inputs.darwin.lib.darwinSystem
        else if coordinate.nativeClass == "nixos"
        then inputs.nixpkgs.lib.nixosSystem
        else throw "dendritic.configurations: unsupported target system ${coordinate.hostPlatform.system}";
      nixpkgsPlatformModules = [
        {nixpkgs.buildPlatform = coordinate.hostPlatform.system;}
        {nixpkgs.hostPlatform = coordinate.hostPlatform.system;}
      ];
    in
      constructor {
        # Keep nixpkgs.pkgs unset: the native evaluator performs the normal
        # nixpkgs splice from these build/host platform options.
        inherit (coordinate) specialArgs;
        modules =
          nixpkgsPlatformModules
          ++ [
            {_module.args = coordinate.lateModuleArgs;}
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
          coordinate.users
          ++ lib.optional (coordinate.users != {}) {
            home-manager.extraSpecialArgs = lib.mergeAttrsList (lib.mapAttrsToList (_: user: user.extraSpecialArgs) coordinate.users);
          }
          ++ coordinate.modules;
      });

  configuration = coordinate: let
    root = baseConfiguration coordinate;
    includedSpecialisations = lib.filterAttrs (_: variant:
      if variant.includeSpecialisations != null
      then variant.includeSpecialisations
      else config.dendritic.configurations.defaults.variants.includeSpecialisations)
    coordinate.variants;
  in
    if includedSpecialisations == {}
    then root
    else if coordinate.nativeClass == "darwin"
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
      config.dendritic.configurations.defaults.variants.enableFlakeOutputs
      && config.dendritic.configurations.defaults.variants.enable
      && variant.enableFlakeOutput
      && variant.enable)
    coordinate.variants);
in {
  flake = {
    nixosConfigurations = lib.mkMerge (lib.concatMap outputRows (lib.filter (coordinate: coordinate.nativeClass == "nixos") systemCoordinates));
    darwinConfigurations = lib.mkMerge (lib.concatMap outputRows (lib.filter (coordinate: coordinate.nativeClass == "darwin") systemCoordinates));
  };
}
