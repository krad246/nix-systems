{withSystem, ...}: let
  # Generate a wrapper Makefile handling the container activations.
  # Given some 'hostCtx' and a mapped 'mappedCtx':
  # - Build the vscode-devcontainer package from the mapped system
  # - Create a makefile derivation using 'hostPkgs' but pointing to the mapped vscode-devcontainer.
  mkContainer = hostCtx: {system ? hostCtx.pkgs.stdenv.system, ...}:
    withSystem system (mappedCtx: let
      vscode-devcontainer = hostCtx.pkgs.dockerTools.streamLayeredImage {
        name = "vscode-devcontainer";
        architecture = mappedCtx.pkgs.go.GOARCH;

        fromImage = mappedCtx.self'.packages.ubuntu;

        contents = let
          mkEnv = {pkgs, ...}:
            pkgs.buildEnv {
              name = "vscode-devcontainer-contents";
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
          cat <<- EOF > ./etc/nix/nix.conf
          experimental-features = nix-command flakes
          ${mappedCtx.pkgs.lib.strings.optionalString hostCtx.pkgs.stdenv.isDarwin "filter-syscalls = false"}
          EOF
        '';
      };
    in
      vscode-devcontainer);
in {
  perSystem = args @ {
    lib,
    pkgs,
    ...
  }: {
    packages = lib.mkIf pkgs.stdenv.isLinux {
      vscode-devcontainer = mkContainer args;
      ubuntu = pkgs.dockerTools.pullImage {
        imageName = "ubuntu";
        imageDigest = "sha256:83f0c2a8d6f266d687d55b5cb1cb2201148eb7ac449e4202d9646b9083f1cee0";
        sha256 = "sha256-5y6ToMw1UGaLafjaN69YabkjyCX61FT3QxU4mtmXMP0=";
        finalImageName = "ubuntu";
        finalImageTag = "latest";
        os = pkgs.go.GOOS;
        arch = pkgs.go.GOARCH;
      };
    };
  };

  flake.packages.aarch64-darwin.vscode-devcontainer = withSystem "aarch64-darwin" (hostCtx: let
    vscode-devcontainer = mkContainer hostCtx {system = "aarch64-linux";};
  in
    vscode-devcontainer);
}
