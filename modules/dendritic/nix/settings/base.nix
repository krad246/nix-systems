{self, ...}: {
  flake.modules = {
    generic.nix = {
      nix.settings = {
        experimental-features = [
          "ca-derivations"
          "dynamic-derivations"
          "flakes"
          "nix-command"
          "recursive-nix"
          # "repl-flake"
        ];

        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        # Store Nix user environment pointers in each user's home directory.
        use-xdg-base-directories = true;
      };
    };

    darwin.nix = {
      imports = [self.modules.generic.nix];

      # Recent macOS releases shifted the expected nixbld group ID space.
      # Pin the build user group to the modern Darwin-compatible value so
      # nix-darwin deployments remain interoperable with existing multi-user
      # Nix installations across upgrades and fresh installs.
      ids.gids.nixbld = 350;
    };

    homeManager.nix = {
      imports = [self.modules.generic.nix];
    };

    nixos.nix = {
      imports = [self.modules.generic.nix];
    };
  };
}
