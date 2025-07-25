{
  withSystem,
  inputs,
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      ./agenix.nix
      ./auto-update.nix
      ./dark-mode.nix
      ./dock.nix
      ./finder.nix
      ./firewall.nix
      ./hm-compat.nix
      ./homebrew.nix
      ./keyboard.nix
      ./linux-builder.nix
      ./mac-app-util.nix
      ./menubar.nix
      ./pointer.nix
      ./single-user.nix
      ./spotlight.nix
      ./touch-id.nix
      ./window-manager.nix
    ]
    ++ (with self.modules.generic; [
      system-link-registry
      flake-registry
      lorri
      nix-core
      unfree
    ]);

  fonts.packages = withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts.paths);

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
    daemonIOLowPriority = lib.modules.mkDefault true;
    daemonProcessType = lib.modules.mkDefault "Adaptive";

    settings = {
      auto-optimise-store = false;
      extra-sandbox-paths = ["/nix/store"];
      auto-allocate-uids = false;
    };
  };

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
    variables.NIX_REMOTE = "daemon";
  };

  nixpkgs.overlays = [
    inputs.nixpkgs-firefox-darwin.overlay
  ];
}
