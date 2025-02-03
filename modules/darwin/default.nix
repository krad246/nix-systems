{
  withSystem,
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  imports =
    (with self.darwinModules;
      [
        system-preferences
      ]
      ++ [
        hm-compat
        homebrew
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
    configureBuildUsers = true;
    daemonIOLowPriority = lib.modules.mkDefault true;
    daemonProcessType = lib.modules.mkDefault "Adaptive";
    settings = {
      auto-optimise-store = false;
    };
  };

  services.nix-daemon.enable = lib.modules.mkForce true;
  system.stateVersion = 5;

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
