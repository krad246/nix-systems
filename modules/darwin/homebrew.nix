{
  inputs,
  config,
  pkgs,
  ...
}: let
  inherit (inputs) nix-homebrew;
in {
  imports = [nix-homebrew.darwinModules.nix-homebrew];

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    autoMigrate = true;
    user = config.krad246.darwin.system-preferences.masterUser.owner;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [
      "homebrew/services"
    ];

    global.brewfile = true;
  };

  environment = {
    systemPath = ["${config.homebrew.brewPrefix}"];
    systemPackages = [pkgs.mas];
  };
}
