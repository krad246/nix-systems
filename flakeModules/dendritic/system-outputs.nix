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

  variantModules = coordinate: variant:
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
    coordinate.users;

  baseConfiguration = coordinate: let
    constructor = withSystem coordinate.hostPlatform.system ({pkgs, ...}:
      if pkgs.stdenv.hostPlatform.isDarwin
      then inputs.darwin.lib.darwinSystem
      else if pkgs.stdenv.hostPlatform.isLinux
      then inputs.nixpkgs.lib.nixosSystem
      else throw "dendritic.configurations: unsupported target system ${coordinate.hostPlatform.system}");
  in
    constructor {
      modules =
        [
          {nixpkgs.hostPlatform = coordinate.hostPlatform.system;}
          (lib.mkIf (coordinate.buildPlatform.system != coordinate.hostPlatform.system) {
            nixpkgs.buildPlatform = lib.mkIf coordinate.crossCompile coordinate.buildPlatform.system;
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
        coordinate.users
        ++ coordinate.modules;
    };

  configuration = coordinate: let
    root = baseConfiguration coordinate;
    includedSpecialisations = lib.filterAttrs (_: variant:
      if variant.includeSpecialisations != null
      then variant.includeSpecialisations
      else config.dendritic.configurations.variants.includeSpecialisations)
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
              lib.mapAttrs (_: variant: {
                configuration.imports = variantModules coordinate variant;
              })
              includedSpecialisations;
          }
        ];
      };

  outputRows = coordinate:
    [{${hostOutputName coordinate} = configuration coordinate;}]
    ++ lib.mapAttrsToList (variantName: variant: {
      ${variantOutputName coordinate variantName variant} =
        (baseConfiguration coordinate).extendModules {modules = variantModules coordinate variant;};
    }) (lib.filterAttrs (_: variant:
      config.dendritic.configurations.variants.build
      && config.dendritic.configurations.variants.enable
      && variant.build
      && variant.enable)
    coordinate.variants);
in {
  flake = {
    nixosConfigurations = lib.mkMerge (lib.concatMap outputRows (lib.filter (coordinate: coordinate.nativeClass == "nixos") systemCoordinates));
    darwinConfigurations = lib.mkMerge (lib.concatMap outputRows (lib.filter (coordinate: coordinate.nativeClass == "darwin") systemCoordinates));
  };
}
