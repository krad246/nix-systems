{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  systemCoordinates = config.dendritic.internal.systemCoordinates;
  profileNames = config.dendritic.internal.profileNames;

  profileSystemModules = nativeClass: tags:
    lib.concatMap (tag: let
      contribution = config.dendritic.configurations.perTag.${tag}.perClass.${nativeClass} or {};
    in
      assert lib.assertMsg (lib.elem tag profileNames) "dendritic.configurations: tag ${tag} is not a canonical profile aspect";
        contribution.modules or [])
    tags;

  profileHomeModules = username: tags:
    lib.concatMap (tag: let
      contribution = config.dendritic.configurations.perTag.${tag}.perClass.homeManager or {};
    in
      (contribution.modules or []) ++ (contribution.users.${username}.modules or []))
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

  packageCoordinates = lib.concatMap (normalized:
    map (variantName: {
      inherit normalized variantName;
      variant = normalized.declaration.variants.${variantName};
    }) (builtins.attrNames (lib.filterAttrs (_: variant:
      config.dendritic.configurations.variants.enableFlakeOutputs
      && config.dendritic.configurations.variants.enable
      && variant.enableFlakeOutput
      && variant.enable
      && variant.package != null)
    normalized.declaration.variants)))
  config.dendritic.internal.systemCoordinates;

  variantModules = normalized: variant:
    [{_module.args = variant.lateModuleArgs;}]
    ++ profileSystemModules normalized.nativeClass variant.tags
    ++ variant.modules
    ++ lib.mapAttrsToList (username: _: {
      home-manager.users.${username}.imports =
        profileHomeModules username variant.tags
        ++ (variant.users.${username}.modules or []);
    })
    normalized.users;

  baseConfiguration = coordinate:
    withSystem coordinate.normalized.hostPlatform.system ({pkgs, ...}: let
      constructor =
        if pkgs.stdenv.hostPlatform.isDarwin
        then inputs.darwin.lib.darwinSystem
        else if pkgs.stdenv.hostPlatform.isLinux
        then inputs.nixpkgs.lib.nixosSystem
        else throw "dendritic.configurations: unsupported target system ${coordinate.normalized.hostPlatform.system}";
      pkgsModules =
        lib.optionals pkgs.stdenv.hostPlatform.isLinux [inputs.nixpkgs.nixosModules.readOnlyPkgs]
        ++ [{nixpkgs.pkgs = pkgs;}];
      platformModules = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        {nixpkgs.hostPlatform = coordinate.normalized.hostPlatform.system;}
      ];
    in
      constructor {
        # The package set is selected at the concrete build/host boundary;
        # declaration layers remain target-independent.
        specialArgs = coordinate.normalized.specialArgs;
        modules =
          pkgsModules
          ++ platformModules
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

  selectedPackages = buildSystem:
    lib.concatMap (coordinate: let
      root = baseConfiguration coordinate;
      variantConfiguration =
        if variantModules coordinate.normalized coordinate.variant == []
        then root
        else
          root.extendModules {
            specialArgs = lib.mergeAttrsList [coordinate.variant.specialArgs coordinate.variant.extraSpecialArgs];
            modules = variantModules coordinate.normalized coordinate.variant;
          };
    in
      lib.optional (coordinate.normalized.buildPlatform.system == buildSystem) {
        "${variantOutputName coordinate.normalized coordinate.variantName coordinate.variant}" =
          coordinate.variant.package variantConfiguration;
      })
    packageCoordinates;
in {
  perSystem = {system, ...}: {
    packages = lib.mkMerge (selectedPackages system);
  };
}
