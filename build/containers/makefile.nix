{withSystem, ...}: let
  # Generate a wrapper Makefile handling the container activations.
  # Given some 'hostCtx' and a mapped 'mappedCtx':
  # - Build the vscode-devcontainer package from the mapped system
  # - Create a makefile derivation using 'hostPkgs' but pointing to the mapped vscode-devcontainer.
  mkMakefile = {
    hostCtx,
    system ? hostCtx.pkgs.stdenv.system,
    ...
  }:
    withSystem system (mappedCtx: let
      inherit (hostCtx.self'.packages) vscode-devcontainer;
      image = "${vscode-devcontainer.imageName}:${vscode-devcontainer.imageTag}";
    in
      hostCtx.pkgs.substituteAll rec {
        src = ./Makefile.in;
        inherit image;
        loader = vscode-devcontainer;

        # Generate a devcontainer.json with the 'image' parameter set to this flake's vscode-devcontainer.
        template = hostCtx.pkgs.substituteAll {
          src = ./devcontainer.json.in;
          inherit image;
          platform = "${mappedCtx.pkgs.go.GOOS}/${mappedCtx.pkgs.go.GOARCH}";
        };
      });
in {
  perSystem = args @ {
    self',
    lib,
    pkgs,
    ...
  }: {
    packages = lib.mkIf pkgs.stdenv.isLinux {
      makefile = mkMakefile {hostCtx = args // self';};
    };
  };

  flake.packages = {
    x86_64-linux.makefile-aarch64-linux =
      withSystem "x86_64-linux"
      (hostCtx: let
        makefile =
          mkMakefile
          {
            inherit hostCtx;
            system = "aarch64-linux";
          };
      in
        makefile);

    aarch64-linux.makefile-x86_64-linux = withSystem "aarch64-linux" (hostCtx: let
      makefile =
        mkMakefile
        {
          inherit hostCtx;
          system = "x86_64-linux";
        };
    in
      makefile);

    aarch64-darwin = rec {
      makefile = makefile-aarch64-linux;
      makefile-aarch64-linux = withSystem "aarch64-darwin" (hostCtx: let
        makefile = mkMakefile {
          inherit hostCtx;
          system = "aarch64-linux";
        };
      in
        makefile);

      makefile-x86_64-linux =
        withSystem "aarch64-darwin"
        (
          hostCtx: let
            makefile = mkMakefile {
              inherit hostCtx;
              system = "x86_64-linux";
            };
          in
            makefile
        );
    };
  };
}
