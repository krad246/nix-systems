{
  config,
  inputs,
  lib,
  ...
}: {
  config = {
    flake-file.inputs.dendritic = {
      url = "github:krad246/nix-systems/dendritic";

      inputs = {
        agenix.follows = "agenix";
        agenix-shell.follows = "agenix-shell";
        disko.follows = "disko";
        flake-compat.follows = "flake-compat";
        flake-file.follows = "flake-file";
        flake-parts.follows = "flake-parts";
        flake-root.follows = "flake-root";
        home-manager.follows = "home-manager";
        impermanence.follows = "impermanence";
        just-flake.follows = "just-flake";
        nix-darwin.follows = "darwin";
        nix-homebrew.follows = "nix-homebrew";
        nixos-wsl.follows = "nixos-wsl";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-lib.follows = "nixpkgs";
        nixpkgs-unstable.follows = "nixpkgs-unstable";
        pre-commit-hooks-nix.follows = "pre-commit-hooks-nix";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    # Stable migration seam. Consumers use this namespace while its values are
    # progressively replaced with modules materialized in the current tree.
    flake.dendritic = {
      inherit (inputs.dendritic) darwinModules nixosModules;

      modules = {
        inherit (inputs.dendritic.modules) nixos darwin;
        homeManager = {
          identity = config.flake.modules.homeManager.identity;
          base = config.flake.modules.homeManager.base;

          desktop.imports = [
            inputs.dendritic.modules.homeManager.browser
            inputs.dendritic.modules.homeManager.terminal
          ];

          dev = {
            imports = [inputs.dendritic.modules.homeManager.editor];
            shell.profiles.dev.enable = true;
            picker.backends.fzf.integrations.helix.enable = lib.mkDefault true;
          };

          interactive = {
            shell.profiles.interactive.enable = true;
          };

          secrets = {
            imports = [inputs.dendritic.modules.homeManager.rbw];
            identity.secrets.backends.rbw.enable = lib.mkDefault true;
          };

          nixbook-pro.imports = [
            config.flake.dendritic.modules.homeManager.desktop
            config.flake.dendritic.modules.homeManager.dev
            config.flake.dendritic.modules.homeManager.interactive
            config.flake.dendritic.modules.homeManager.secrets
            {
              browser.backends.zen = {
                enable = lib.mkDefault true;
                default = lib.mkDefault true;
              };
            }
          ];
        };
      };
    };
  };
}
