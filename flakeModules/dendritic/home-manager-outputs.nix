{
  config,
  inputs,
  lib,
  ...
}: let
  profileNames = config.dendritic.internal.profileNames;

  profileHomeModules = username: tags:
    lib.concatMap (tag: let
      overlay = config.dendritic.configurations.perTag.${tag} or {};
    in
      assert lib.assertMsg (lib.elem tag profileNames) "dendritic.configurations: tag ${tag} is not a canonical profile aspect";
        (overlay.homeModules or []) ++ (overlay.users.${username}.modules or []))
    tags;

  homeClassModules = username: let
    layer = config.dendritic.configurations.perClass.home or {};
  in
    (layer.homeModules or []) ++ (layer.users.${username}.modules or []);

  variantModules = username: variant:
    profileHomeModules username variant.tags
    ++ variant.modules
    ++ variant.homeModules
    ++ (variant.users.${username}.modules or []);

  variantOutputName = parentName: variantName: variant:
    if variant.outputName == null
    then "${parentName}-${variantName}"
    else variant.outputName;

  standaloneDeclarations = lib.mapAttrs (username: user: {
    inherit username;
    inherit (user) variants passInOsConfig;
    inherit (user.standalone) pkgs outputName;
    modules =
      homeClassModules username
      ++ profileHomeModules username config.dendritic.configurations.tags
      ++ user.modules
      ++ profileHomeModules username user.tags
      ++ user.standalone.modules;
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
                configuration.imports = variantModules declaration.username variant;
              })
              includedSpecialisations;
          }
        ];
      };

  outputRows = pkgs: name: declaration:
    [{${name} = configuration pkgs declaration;}]
    ++ lib.mapAttrsToList (variantName: variant: {
      ${variantOutputName name variantName variant} =
        (baseConfiguration pkgs declaration).extendModules {modules = variantModules declaration.username variant;};
    }) (lib.filterAttrs (_: variant:
      config.dendritic.configurations.variants.build
      && config.dendritic.configurations.variants.enable
      && variant.build
      && variant.enable)
    declaration.variants);

  hostUserRows = lib.concatLists (lib.concatMap (hostName: let
    hostDeclaration = config.dendritic.internal.systemDeclarations.${hostName};
    host = config.flake.nixosConfigurations.${hostName} or config.flake.darwinConfigurations.${hostName};
  in
    lib.mapAttrsToList (username: userLayer: let
      user = config.dendritic.configurations.users.${username};
      name =
        if userLayer.outputName == null
        then "${username}-${hostName}"
        else userLayer.outputName;
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
      lib.concatLists (lib.mapAttrsToList (_: declaration:
        outputRows declaration.pkgs (
          if declaration.outputName == null
          then declaration.username
          else declaration.outputName
        )
        declaration)
      standaloneDeclarations)
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
