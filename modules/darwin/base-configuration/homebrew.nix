{
  inputs,
  config,
  lib,
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
  };

  homebrew = {
    enable = lib.modules.mkDefault false;
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
