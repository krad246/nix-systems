{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  systemCoordinates = config.dendritic.internal.systemCoordinates;

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

  packageCoordinates = lib.concatMap (normalized:
    map (variantName: {
      inherit normalized variantName;
      variant = normalized.declaration.variants.${variantName};
    }) (builtins.attrNames (lib.filterAttrs (_: variant:
      config.dendritic.configurations.variants.build
      && config.dendritic.configurations.variants.enable
      && variant.build
      && variant.enable
      && variant.package != null)
    normalized.declaration.variants)))
  config.dendritic.internal.systemCoordinates;

  variantModules = normalized: variant:
    variant.modules
    ++ lib.concatMap (tag: config.dendritic.configurations.perTag.${tag}.modules or []) variant.tags
    ++ lib.mapAttrsToList (username: _: {
      home-manager.users.${username}.imports =
        variant.homeModules
        ++ (variant.users.${username}.modules or [])
        ++ lib.concatMap (tag: let
          layer = config.dendritic.configurations.perTag.${tag} or {};
        in
          (layer.homeModules or []) ++ (layer.users.${username}.modules or []))
        variant.tags;
    })
    normalized.users;

  baseConfiguration = coordinate: let
    constructor = withSystem coordinate.normalized.hostPlatform.system ({pkgs, ...}:
      if pkgs.stdenv.hostPlatform.isDarwin
      then inputs.darwin.lib.darwinSystem
      else inputs.nixpkgs.lib.nixosSystem);
  in
    constructor {
      modules =
        [
          {nixpkgs.hostPlatform = coordinate.normalized.hostPlatform.system;}
          (lib.mkIf (coordinate.normalized.buildPlatform.system != coordinate.normalized.hostPlatform.system) {
            nixpkgs.buildPlatform = lib.mkIf coordinate.normalized.crossCompile coordinate.normalized.buildPlatform.system;
          })
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
    };

  selectedPackages = buildSystem:
    lib.concatMap (coordinate: let
      root = baseConfiguration coordinate;
      variantConfiguration =
        if variantModules coordinate.normalized coordinate.variant == []
        then root
        else root.extendModules {modules = variantModules coordinate.normalized coordinate.variant;};
    in
      lib.optional (coordinate.normalized.buildPlatform.system == buildSystem) {
        "${variantOutputName coordinate.normalized coordinate.variantName coordinate.variant}-${coordinate.normalized.hostPlatform.system}" =
          coordinate.variant.package variantConfiguration;
      })
    packageCoordinates;
in {
  perSystem = {system, ...}: {
    packages = lib.mkMerge (selectedPackages system);
  };
}
