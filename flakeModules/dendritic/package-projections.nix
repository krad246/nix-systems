{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  packageCoordinates = lib.concatLists (lib.mapAttrsToList (hostName: declaration:
    lib.concatMap (hostPlatform: let
      buildPlatform =
        if declaration.buildPlatform == null
        then hostPlatform
        else declaration.buildPlatform;
      platform = lib.systems.parse.mkSystemFromString hostPlatform.system;
      expectedClass =
        if lib.systems.inspect.predicates.isDarwin platform
        then "darwin"
        else if lib.systems.inspect.predicates.isLinux platform
        then "nixos"
        else throw "dendritic.configurations: unsupported host platform ${hostPlatform.system}";
      normalized = assert lib.assertMsg (declaration.class == expectedClass) "dendritic.configurations: class ${declaration.class} conflicts with host platform ${hostPlatform.system}";
      assert lib.assertMsg (buildPlatform.system == hostPlatform.system || declaration.crossCompile) "dendritic.configurations: host platform ${hostPlatform.system} requires crossCompile = true for build platform ${buildPlatform.system}"; {
        inherit hostName hostPlatform buildPlatform;
        inherit (declaration) class crossCompile users;
        modules = declaration.modules ++ (config.dendritic.configurations.perSystem.${hostPlatform.system}.modules or []);
      };
    in
      map (variantName: {
        inherit normalized variantName;
        variant = declaration.variants.${variantName};
      }) (builtins.attrNames (lib.filterAttrs (_: variant: variant.package != null) declaration.variants)))
    declaration.hostPlatforms)
  config.dendritic.internal.systemDeclarations);

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
        if coordinate.variant.modules == []
        then root
        else root.extendModules {inherit (coordinate.variant) modules;};
    in
      lib.optional (coordinate.normalized.buildPlatform.system == buildSystem) {
        ${
          config.dendritic.configurations.variants.nameFunction {
            host = coordinate.normalized.hostName;
            package = coordinate.variantName;
            hostPlatform = coordinate.normalized.hostPlatform.system;
          }
        } =
          coordinate.variant.package variantConfiguration;
      })
    packageCoordinates;
in {
  perSystem = {system, ...}: {
    packages = lib.mkMerge (selectedPackages system);
  };
}
