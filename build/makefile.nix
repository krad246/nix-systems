{withSystem, ...}: let
  # Generate a wrapper Makefile handling the container activations.
  # Given some 'hostPkgs' and a mapped 'system':
  # - Grab the devshell package from the mapped system
  # - Create a makefile derivation using 'hostPkgs' but pointing to the mapped devshell.
  mkMakefile = hostPkgs: {system ? hostPkgs.stdenv.system, ...}:
    withSystem system ({self', ...}: let
      inherit (self'.packages) devshell;
      image = "${devshell.imageName}:${devshell.imageTag}";
    in
      hostPkgs.substituteAll rec {
        src = ./Makefile.in;
        inherit devshell image;

        # Generate a devcontainer.json with the 'image' parameter set to this flake's devshell.
        template = hostPkgs.substituteAll {
          src = ./devcontainer.json.in;
          inherit image;
        };
      });
in {
  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    packages = lib.mkIf pkgs.stdenv.isLinux {
      makefile = mkMakefile pkgs;
    };
  };

  flake.packages.aarch64-darwin.makefile = withSystem "aarch64-darwin" ({pkgs, ...}: let
    hostPkgs = pkgs;
    makefile = mkMakefile hostPkgs {system = "aarch64-linux";};
  in
    makefile);
}
