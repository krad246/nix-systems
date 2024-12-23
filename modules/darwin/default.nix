{
  withSystem,
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  imports =
    (with self.darwinModules; [
      auto-update
      dark-mode
      dock
      finder
      firewall
      keyboard
      menubar
      pointer
      single-user
      touch-id
      window-manager
    ])
    ++ (with self.darwinModules; [
      agenix
      arc
      hm-compat
      homebrew
      kitty
      linux-builder
      mac-app-util
      magnet
      vscode
    ])
    ++ (with self.modules.generic; [
      system-link-registry
      flake-registry
      nix-core
      unfree
    ]);

  fonts.packages = [(withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts))];

  system.defaults = {
    NSGlobalDomain = {
      NSDisableAutomaticTermination = false;
      NSDocumentSaveNewDocumentsToCloud = true;

      "com.apple.sound.beep.volume" = 0.5;
      "com.apple.springing.enabled" = true;
    };
  };

  networking = {
    localHostName = config.networking.hostName;
    computerName = config.networking.hostName;
  };

  nix = {
    useDaemon = lib.modules.mkForce true;
    settings = {
      auto-optimise-store = false;
      sandbox = false;
    };
  };

  services.nix-daemon.enable = lib.modules.mkForce true;
  system.stateVersion = 4;

  homebrew = {
    brews = ["bash" "zsh"];
  };

  environment = {
    shells = [
      "${config.homebrew.brewPrefix}/bash"
      "${config.homebrew.brewPrefix}/zsh"
    ];

    systemPackages = with pkgs; ([m-cli] ++ [coreutils just tldr safe-rm] ++ [duf dust]);
  };
}
