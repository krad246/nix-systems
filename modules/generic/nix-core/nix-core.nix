{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) modules;
in {
  nix = {
    package = modules.mkDefault pkgs.nixVersions.stable;
    checkConfig = true;
    gc.automatic = true;
    settings = {
      experimental-features = ["nix-command" "flakes"] ++ (lib.lists.optionals pkgs.stdenv.isLinux ["cgroups" "local-overlay-store"]);
      preallocate-contents = true;
      use-xdg-base-directories = true;

      keep-going = true;
      max-jobs = "auto";
      max-substitution-jobs = modules.mkDefault 32;

      auto-optimise-store = modules.mkDefault false;
      min-free = modules.mkDefault (12 * 1024 * 1024 * 1024);

      keep-outputs = modules.mkDefault true;
      keep-derivations = modules.mkDefault false;

      builders-use-substitutes = true;
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
        "krad246.cachix.org-1:N57J9SfNFtxMSYnlULH4l7ZkdNjIQb0ByyapaEb/8IM="
      ];

      connect-timeout = modules.mkDefault 300;
      timeout = modules.mkDefault 1800;
      max-silent-time = modules.mkDefault 3600;

      sandbox = modules.mkForce true;
      sandbox-fallback = modules.mkForce true;
    };
  };
}
