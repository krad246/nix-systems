{
  config,
  lib,
  pkgs,
  ...
}: {
  nix = {
    package = pkgs.nixFlakes;
    checkConfig = true;
    gc.automatic = true;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      keep-outputs = lib.mkDefault false;
      keep-derivations = lib.mkDefault false;
      auto-optimise-store = false;
      sandbox = lib.mkDefault false;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://krad246.cachix.org"
      ];
      trusted-substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://krad246.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "krad246.cachix.org-1:naxMicfqW5ZWr7XNZeLfAT3YHWCDLs3noY0aI3eBfvQ="
      ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
    '';

    useDaemon = true;
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "dullahan.local";
        system = "aarch64-darwin";
        maxJobs = 16;
        speedFactor = 1;
        sshKey = config.age.secrets."id_ed25519_priv.age".path;
      }
    ];
  };

  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;
  system.stateVersion = 4;
}
