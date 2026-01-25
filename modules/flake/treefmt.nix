{
  inputs,
  withSystem,
  ...
}: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  flake-file = {
    formatter = pkgs:
      withSystem pkgs.stdenv.hostPlatform.system
      ({config, ...}: let
        treefmt = pkgs.treefmt.withConfig {
          inherit (config.treefmt) settings;
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
      treefmt-nix.url = "github:numtide/treefmt-nix";
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
        shfmt.enable = true;
        statix.enable = true;
        typos.enable = true;
      };
      settings = {
        on-unmatched = "debug";
      };
    };
  };
}
