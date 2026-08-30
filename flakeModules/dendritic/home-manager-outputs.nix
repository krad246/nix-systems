{
  config,
  inputs,
  lib,
  ...
}: let
  profileNames = config.dendritic.internal.profileNames;

  mergeArgs = field: contributions:
    lib.mergeAttrsList (map (contribution: contribution.${field} or {}) contributions);

  profileHomeModules = username: tags:
    lib.concatMap (tag: let
      contribution = config.dendritic.configurations.perTag.${tag}.perClass.homeManager or {};
    in
      assert lib.assertMsg (lib.elem tag profileNames) "dendritic.configurations: tag ${tag} is not a canonical profile aspect";
        (contribution.modules or []) ++ (contribution.users.${username}.modules or []))
    tags;

  standaloneModules = user:
    if user.standalone == null
    then []
    else user.standalone.modules;

  variantModules = username: variant:
    [{_module.args = variant.lateModuleArgs;}]
    ++ profileHomeModules username variant.tags
    ++ variant.modules
    ++ (variant.users.${username}.modules or []);

  variantOutputName = parentName: variantName: variant:
    if variant.outputName == null
    then "${parentName}-${variantName}"
    else variant.outputName;

  standaloneDeclarations = lib.mapAttrs (username: user: let
    tagContributions = map (tag: config.dendritic.configurations.perTag.${tag}.perClass.homeManager or {}) (
      config.dendritic.configurations.tags ++ user.tags
    );
    standaloneContributions = tagContributions ++ [user user.standalone];
  in {
    inherit username;
    inherit (user) variants passInOsConfig;
    inherit (user.standalone) pkgs outputName;
    extraSpecialArgs = lib.mergeAttrsList [
      config.dendritic.configurations.globalArgs
      config.dendritic.configurations.earlyModuleArgs
      (mergeArgs "specialArgs" standaloneContributions)
      (mergeArgs "extraSpecialArgs" standaloneContributions)
    ];
    lateModuleArgs = lib.mergeAttrsList [
      config.dendritic.configurations.lateModuleArgs
      (mergeArgs "lateModuleArgs" standaloneContributions)
    ];
    modules =
      profileHomeModules username config.dendritic.configurations.tags
      ++ user.modules
      ++ profileHomeModules username user.tags
      ++ user.standalone.modules;
  }) (lib.filterAttrs (_: user: user.enable && user.standalone != null) config.dendritic.configurations.users);

  baseConfiguration = pkgs: declaration:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules =
        [
          {_module.args = declaration.lateModuleArgs;}
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
      ${variantOutputName name variantName variant} = (baseConfiguration pkgs declaration).extendModules {
        specialArgs = lib.mergeAttrsList [variant.specialArgs variant.extraSpecialArgs];
        modules = variantModules declaration.username variant;
      };
    }) (lib.filterAttrs (_: variant:
      config.dendritic.configurations.variants.enableFlakeOutputs
      && config.dendritic.configurations.variants.enable
      && variant.enableFlakeOutput
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
        modules = standaloneModules user ++ userLayer.modules;
        inherit (user) variants;
        extraSpecialArgs = lib.mergeAttrsList [
          config.dendritic.configurations.globalArgs
          config.dendritic.configurations.earlyModuleArgs
          user.extraSpecialArgs
          userLayer.extraSpecialArgs
          (lib.optionalAttrs user.passInOsConfig {osConfig = host.config;})
        ];
        lateModuleArgs = lib.mergeAttrsList [
          config.dendritic.configurations.lateModuleArgs
          user.lateModuleArgs
          userLayer.lateModuleArgs
        ];
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
    lib.mkIf (standaloneDeclarations != {}) (let
      standalone = configuration pkgs (builtins.head (lib.attrValues standaloneDeclarations));
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
