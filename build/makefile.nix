{withSystem, ...}: let
  # Generate a wrapper Makefile handling the container activations.
  # Given some 'hostCtx' and a mapped 'mappedCtx':
  # - Build the devshell package from the mapped system
  # - Create a makefile derivation using 'hostPkgs' but pointing to the mapped devshell.
  mkMakefile = hostCtx: {system ? hostCtx.pkgs.stdenv.system, ...}:
    withSystem system (mappedCtx: let
      devshell = hostCtx.pkgs.dockerTools.streamLayeredImage {
        name = "devshell";
        architecture = mappedCtx.pkgs.go.GOARCH;

        fromImage = hostCtx.pkgs.dockerTools.pullImage {
          imageName = "ubuntu";
          imageDigest = "sha256:83f0c2a8d6f266d687d55b5cb1cb2201148eb7ac449e4202d9646b9083f1cee0";
          sha256 = "sha256-5y6ToMw1UGaLafjaN69YabkjyCX61FT3QxU4mtmXMP0=";
          finalImageName = "ubuntu";
          finalImageTag = "latest";
          os = mappedCtx.pkgs.go.GOOS;
          arch = mappedCtx.pkgs.go.GOARCH;
        };

        contents = let
          mkEnv = {pkgs, ...}:
            pkgs.buildEnv {
              name = "devshell-contents";
              paths = with pkgs;
                [bashInteractive]
                ++ [dockerTools.binSh dockerTools.usrBinEnv dockerTools.fakeNss]
                ++ [git]
                ++ [direnv nix-direnv]
                ++ [just gnumake]
                ++ [
                  shellcheck
                  nil
                  nix-tree
                ];

              pathsToLink = ["/bin" "/share"];
            };
        in
          mkEnv mappedCtx;

        fakeRootCommands = ''
          mkdir -p ./nix/{store,var/nix} ./etc/nix
          echo 'experimental-features = nix-command flakes' >./etc/nix/nix.conf
        '';
      };

      image = "${devshell.imageName}:${devshell.imageTag}";
    in
      hostCtx.pkgs.substituteAll rec {
        src = ./Makefile.in;
        inherit image;
        loader = devshell;

        # Generate a devcontainer.json with the 'image' parameter set to this flake's devshell.
        template = hostCtx.pkgs.substituteAll {
          src = ./devcontainer.json.in;
          inherit image;
          platform = "${mappedCtx.pkgs.go.GOOS}/${mappedCtx.pkgs.go.GOARCH}";
        };
      });
in {
  perSystem = args @ {
    lib,
    pkgs,
    ...
  }: {
    packages = lib.mkIf pkgs.stdenv.isLinux {
      makefile = mkMakefile args;
    };
  };

  flake.packages.aarch64-darwin.makefile = withSystem "aarch64-darwin" (hostCtx: let
    makefile = mkMakefile hostCtx {system = "aarch64-linux";};
  in
    makefile);
}
