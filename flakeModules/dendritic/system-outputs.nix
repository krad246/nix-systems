{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  systemCoordinates = lib.concatLists (lib.mapAttrsToList (hostName: declaration:
    map (hostPlatform: let
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
    in
      assert lib.assertMsg (declaration.class == expectedClass) "dendritic.configurations: class ${declaration.class} conflicts with host platform ${hostPlatform.system}";
      assert lib.assertMsg (buildPlatform.system == hostPlatform.system || declaration.crossCompile) "dendritic.configurations: host platform ${hostPlatform.system} requires crossCompile = true for build platform ${buildPlatform.system}"; {
        inherit hostName hostPlatform buildPlatform;
        inherit (declaration) class crossCompile users variants;
        modules = declaration.modules ++ (config.dendritic.configurations.perSystem.${hostPlatform.system}.modules or []);
      })
    declaration.hostPlatforms)
  config.dendritic.internal.systemDeclarations);

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
    else if coordinate.class == "darwin"
    then throw "nix-darwin configurations do not support included specialisations"
    else
      root.extendModules {
        modules = [
          {
            specialisation =
              lib.mapAttrs (_: variant: {
                configuration.imports = variant.modules;
              })
              includedSpecialisations;
          }
        ];
      };

  outputRows = coordinate:
    [{${coordinate.hostName} = configuration coordinate;}]
    ++ lib.mapAttrsToList (variantName: variant: {
      ${
        config.dendritic.configurations.variants.nameFunction {
          host = coordinate.hostName;
          variant = variantName;
        }
      } =
        (baseConfiguration coordinate).extendModules {inherit (variant) modules;};
    }) (lib.filterAttrs (_: variant: config.dendritic.configurations.variants.enable && variant.enable) coordinate.variants);
in {
  flake = {
    nixosConfigurations = lib.mkMerge (lib.concatMap outputRows (lib.filter (coordinate: coordinate.class == "nixos") systemCoordinates));
    darwinConfigurations = lib.mkMerge (lib.concatMap outputRows (lib.filter (coordinate: coordinate.class == "darwin") systemCoordinates));
  };
}
