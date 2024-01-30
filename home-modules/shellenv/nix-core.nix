{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  nix = {
    package = lib.mkDefault pkgs.nixFlakes;

    checkConfig = true;
    gc.automatic = true;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      keep-outputs = lib.attrsets.attrByPath ["nix" "settings" "keep-outputs"] false osConfig;
      keep-derivations = lib.attrsets.attrByPath ["nix" "settings" "keep-derivations"] false osConfig;

      sandbox = lib.attrsets.attrByPath ["nix" "settings" "sandbox"] "relaxed" osConfig;

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
    '';
  };

  nixpkgs.config.allowUnfree = true;
}
