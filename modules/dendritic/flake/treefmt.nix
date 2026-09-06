{
  inputs,
  lib,
  withSystem,
  ...
}: {
  imports = lib.lists.optionals (inputs ? treefmt-nix) [
    inputs.treefmt-nix.flakeModule
  ];

  flake-file = {
    formatter = pkgs:
      withSystem pkgs.stdenv.hostPlatform.system
      ({config, ...}: let
        treefmt = pkgs.treefmt.withConfig {
          settings =
            config.treefmt.settings
            // {
              tree-root = ".";
              verbose = true;
            };
          runtimeInputs = builtins.attrValues config.treefmt.build.programs;
        };
      in
        pkgs.symlinkJoin {
          name = "treefmt";
          paths = [treefmt] ++ treefmt.passthru.runtimeInputs;
          nativeBuildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/treefmt --add-flags '--no-cache'
          '';
        });

    inputs = {
      treefmt-nix = {
        url = "github:numtide/treefmt-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };
  };

  perSystem = {config, ...}: {
    treefmt = {
      inherit (config.flake-root) projectRootFile;
      flakeCheck = true;
      programs = {
        alejandra.enable = true;
        deadnix = {
          enable = true;
          no-underscore = true;
        };
        just.enable = true;
        keep-sorted.enable = true;
        shellcheck.enable = true;
        # shfmt.enable = true;
        statix.enable = true;
        typos.enable = true;
      };
      settings = {
        on-unmatched = "info";
      };
    };
  };
}
