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
      use-xdg-base-directories = true;
      builders-use-substitutes = true;
      experimental-features = ["nix-command" "flakes"];
      keep-outputs = modules.mkDefault true;
      keep-derivations = modules.mkDefault false;
      auto-optimise-store = modules.mkDefault false;
      sandbox = modules.mkDefault "relaxed";
      sandbox-fallback = modules.mkDefault pkgs.stdenv.isDarwin;
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
      keep-going = true;
      min-free = modules.mkDefault 12884901888;
      preallocate-contents = true;
    };
  };
}
