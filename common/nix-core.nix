{lib, ...}: {
  nix = {
    checkConfig = true;
    gc.automatic = true;
    settings = {
      builders-use-substitutes = true;
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
      connect-timeout = lib.mkDefault 60;
      timeout = lib.mkDefault 60;
      max-silent-time = lib.mkDefault 60;
      keep-going = true;
      min-free = lib.mkDefault 12884901888;
      preallocate-contents = true;
    };
  };
}
