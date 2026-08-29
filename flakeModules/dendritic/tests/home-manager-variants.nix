{
  config,
  inputs,
  lib,
  ...
}: {
  perSystem = {system, ...}: let
    home = config.flake.homeConfigurations;
    standalone = home.standalone or null;
    standaloneDev = home.standalone-dev or null;
    hostDerived = home.krad246-nixbook-pro-composed;
    nixbook = hostDerived;
    legacyConfiguration = inputs.dendritic.darwinConfigurations.nixbook-pro;
    legacyConfig = legacyConfiguration.config;
    legacy = legacyConfig.home-manager.users.${legacyConfig.owner.username};
    composedConfiguration = config.flake.darwinConfigurations.nixbook-pro-composed;
    composedConfig = composedConfiguration.config;
    composed = composedConfig.home-manager.users.${composedConfig.owner.username};
  in {
    dendritic.assertions = [
      {
        assertion = lib.inPureEvalMode || standalone ? extendModules;
        message = "the public standalone Home Manager output retains the normal result interface";
      }
      {
        assertion = lib.inPureEvalMode || standalone.config.specialisation == {};
        message = "a separately built variant is not implicitly included as a specialisation";
      }
      {
        assertion = lib.inPureEvalMode || standaloneDev ? extendModules;
        message = "the public variant output retains the normal Home Manager result interface";
      }
      {
        assertion = lib.inPureEvalMode || standaloneDev.config.shell.profiles.dev.enable;
        message = "the public standalone-dev output contains its declared module delta";
      }
      {
        assertion = hostDerived.pkgs.stdenv.hostPlatform.system == composedConfiguration.pkgs.stdenv.hostPlatform.system;
        message = "the public user-by-host output inherits its host package set";
      }
      {
        assertion = system != "aarch64-darwin" || composed.home.username == legacy.home.username;
        message = "the composed nixbook-pro user retains the legacy username";
      }
      {
        assertion = lib.inPureEvalMode || system != "aarch64-darwin" || nixbook.config.home.homeDirectory == legacy.home.homeDirectory;
        message = "the standalone nixbook-pro user retains the legacy home directory";
      }
      {
        assertion = system != "aarch64-darwin" || map toString composed.home.packages == map toString legacy.home.packages;
        message = "the composed nixbook-pro package closure matches legacy";
      }
      {
        assertion = lib.inPureEvalMode || system != "aarch64-darwin" || map (package: package.name) (lib.filter (package: package.name != "home-manager") nixbook.config.home.packages) == map (package: package.name) legacy.home.packages;
        message = "the standalone nixbook-pro package inventory matches legacy apart from its owned Home Manager CLI";
      }
      {
        assertion = system != "aarch64-darwin" || builtins.attrNames composed.home.file == builtins.attrNames legacy.home.file;
        message = "the composed nixbook-pro managed-file inventory matches legacy";
      }
      {
        assertion = lib.inPureEvalMode || system != "aarch64-darwin" || builtins.attrNames nixbook.config.xdg.configFile == builtins.attrNames legacy.xdg.configFile;
        message = "the standalone nixbook-pro XDG-file inventory matches legacy";
      }
      {
        assertion = lib.inPureEvalMode || system != "aarch64-darwin" || removeAttrs nixbook.config.home.sessionVariables ["TERMINFO_DIRS"] == removeAttrs legacy.home.sessionVariables ["TERMINFO_DIRS"];
        message = "the standalone nixbook-pro session matches legacy apart from profile-owned terminfo paths";
      }
      {
        assertion = lib.inPureEvalMode || standalone.config.home.username == "krad246";
        message = "the portable standalone user retains its configured identity";
      }
    ];
  };
}
