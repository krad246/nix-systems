{
  config,
  inputs,
  lib,
  ...
}: let
  standaloneDeclarations = lib.mapAttrs (username: user: {
    inherit username;
    inherit (user) variants passInOsConfig;
    inherit (user.standalone) pkgs;
    modules = user.modules ++ user.standalone.modules;
  }) (lib.filterAttrs (_: user: user.enable && user.standalone.enable) config.dendritic.configurations.users);

  baseConfiguration = pkgs: declaration:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules =
        [
          ({pkgs, ...}: {
            home.username = lib.mkDefault declaration.username;
            home.homeDirectory = lib.mkDefault (
              if pkgs.stdenv.hostPlatform.isDarwin
              then "/Users/${declaration.username}"
              else "/home/${declaration.username}"
            );
          })
        ]
        ++ declaration.modules;
      extraSpecialArgs = declaration.extraSpecialArgs or {};
    };

  configuration = pkgs: declaration: let
    root = baseConfiguration pkgs declaration;
    includedSpecialisations = lib.filterAttrs (_: variant:
      if variant.includeSpecialisations != null
      then variant.includeSpecialisations
      else config.dendritic.configurations.variants.includeSpecialisations)
    declaration.variants;
  in
    if includedSpecialisations == {}
    then root
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

  outputRows = pkgs: name: declaration:
    [{${name} = configuration pkgs declaration;}]
    ++ lib.mapAttrsToList (variantName: variant: {
      ${
        config.dendritic.configurations.variants.nameFunction {
          user = name;
          variant = variantName;
        }
      } =
        (baseConfiguration pkgs declaration).extendModules {inherit (variant) modules;};
    }) (lib.filterAttrs (_: variant: config.dendritic.configurations.variants.enable && variant.enable) declaration.variants);

  hostUserRows = lib.concatLists (lib.concatMap (hostName: let
    hostDeclaration = config.dendritic.internal.systemDeclarations.${hostName};
    host = config.flake.nixosConfigurations.${hostName} or config.flake.darwinConfigurations.${hostName};
  in
    lib.mapAttrsToList (username: userLayer: let
      user = config.dendritic.configurations.users.${username};
      name = config.dendritic.configurations.variants.nameFunction {
        user = username;
        inherit hostName;
        host = hostName;
      };
      declaration = {
        inherit username;
        modules = user.standalone.modules ++ userLayer.modules;
        inherit (user) variants;
        extraSpecialArgs = lib.optionalAttrs user.passInOsConfig {osConfig = host.config;};
      };
    in
      outputRows host.pkgs name declaration)
    hostDeclaration.users)
  (builtins.attrNames config.dendritic.internal.systemDeclarations));
in {
  flake = {
    homeConfigurations = lib.mkMerge (
      lib.concatLists (lib.mapAttrsToList (name: declaration: outputRows declaration.pkgs name declaration) standaloneDeclarations)
      ++ hostUserRows
    );
  };

  perSystem = {pkgs, ...}:
    lib.mkIf (standaloneDeclarations ? standalone) (let
      standalone = configuration pkgs standaloneDeclarations.standalone;
    in {
      checks = {
        dendritic-hm-standalone = standalone.activationPackage;
        home-manager-standalone = standalone.activationPackage;
      };
      pre-commit.settings.hooks.realize-dendritic-hm-standalone = {
        enable = true;
        description = "Realize the Dendritic standalone Home Manager configuration before pushing";
        entry = "${lib.meta.getExe' pkgs.nix "nix-store"} --realise ${lib.strings.escapeShellArg (builtins.unsafeDiscardStringContext standalone.activationPackage.drvPath)}";
        always_run = true;
        pass_filenames = false;
        stages = ["pre-push"];
      };
    });
}
