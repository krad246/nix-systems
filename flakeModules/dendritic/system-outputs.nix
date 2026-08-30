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
      contribution = config.dendritic.configurations.perTag.${tag}.perClass.home or {};
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

  variantModules = coordinate: variant:
    [
      {_module.args = variant.lateModuleArgs;}
    ]
    ++ profileSystemModules coordinate.nativeClass variant.tags
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
        else throw "dendritic.configurations: unsupported target system ${coordinate.hostPlatform.system}";
    in
      constructor {
        # `pkgs` is target-scoped and deliberately injected only at this concrete
        # builder boundary; declaration layers remain target-independent.
        specialArgs = lib.mergeAttrsList [coordinate.specialArgs {inherit pkgs;}];
        modules =
          [
            {_module.args = coordinate.lateModuleArgs;}
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
      ${variantOutputName coordinate variantName variant} = (baseConfiguration coordinate).extendModules {
        inherit (variant) specialArgs;
        modules = variantModules coordinate variant;
      };
    }) (lib.filterAttrs (_: variant:
      config.dendritic.configurations.variants.enableFlakeOutputs
      && config.dendritic.configurations.variants.enable
      && variant.enableFlakeOutput
      && variant.enable)
    coordinate.variants);
in {
  flake = {
    nixosConfigurations = lib.mkMerge (lib.concatMap outputRows (lib.filter (coordinate: coordinate.nativeClass == "nixos") systemCoordinates));
    darwinConfigurations = lib.mkMerge (lib.concatMap outputRows (lib.filter (coordinate: coordinate.nativeClass == "darwin") systemCoordinates));
  };
}
