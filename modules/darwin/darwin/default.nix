{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  imports =
    (with self.modules.generic; [
      flake-registry
      nix-core
      unfree
    ])
    ++ (with self.darwinModules; [agenix homebrew hm-compat kitty linux-builder mac-app-util vscode])
    ++ [
      ./settings
    ];

  nix.settings = {
    auto-optimise-store = false;
    sandbox = false;
  };

  nix.useDaemon = lib.modules.mkForce true;
  services.nix-daemon.enable = lib.modules.mkForce true;
  system.stateVersion = 4;

  homebrew = {
    brews = ["bash" "zsh"];
  };

  environment = {
    shells = let
      brewRoot = "${config.homebrew.brewPrefix}";
    in ["${brewRoot}/bash" "${brewRoot}/zsh"];
    systemPackages = with pkgs; ([m-cli] ++ [coreutils just tldr safe-rm] ++ [dust]);
  };
}
