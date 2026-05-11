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
    enable = false;
    enableRosetta = true;
    autoMigrate = true;
  };

  homebrew = {
    enable = false;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [
    ];

    global.brewfile = true;
  };

  environment = {
    systemPath = ["${config.homebrew.brewPrefix}"];
    systemPackages = [pkgs.mas];
  };
}
