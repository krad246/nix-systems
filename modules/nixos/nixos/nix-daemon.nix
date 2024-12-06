{
  pkgs,
  lib,
  ...
}: {
  nix = {
    package = pkgs.nixVersions.stable;
    checkConfig = true;
    gc.automatic = true;
    settings = {
      auto-optimise-store = lib.modules.mkDefault true;
      sandbox = lib.modules.mkDefault "relaxed";

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

      experimental-features = ["nix-command" "flakes"];

      keep-outputs = lib.modules.mkDefault true;
      keep-derivations = lib.modules.mkDefault true;
    };
  };
}
