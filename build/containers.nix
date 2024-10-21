{withSystem, ...}: let
  mkContainer = {
    hostCtx,
    system ? hostCtx.pkgs.stdenv.system,
    ...
  }:
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
                ++ [dockerTools.binSh dockerTools.usrBinEnv dockerTools.fakeNss dockerTools.caCertificates]
                ++ [git]
                ++ [direnv nix-direnv]
                ++ [just gnumake]
                ++ [
                  shellcheck
                  nil
                  nix-tree
                ];

              pathsToLink = ["/bin"];
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
in
  {
    perSystem = args @ {
      lib,
      pkgs,
      ...
    }: {
      packages = lib.mkIf pkgs.stdenv.isLinux {
        vscode-devcontainer = mkContainer {hostCtx = args;};
      };
    };
  }
  // {
    flake.packages = {
      x86_64-linux.ubuntu = withSystem "x86_64-linux" ({pkgs, ...}:
        pkgs.dockerTools.pullImage {
          imageName = "ubuntu";
          imageDigest = "sha256:99c35190e22d294cdace2783ac55effc69d32896daaa265f0bbedbcde4fbe3e5";
          sha256 = "0j32w10gl1p87xj8kll0m2dgfizc3l2jnsdj4n95l960d4a4pmfa";
          finalImageName = "ubuntu";
          finalImageTag = "latest";
          os = "linux";
          arch = "amd64";
        });

      aarch64-linux.ubuntu = withSystem "aarch64-linux" ({pkgs, ...}:
        pkgs.dockerTools.pullImage {
          imageName = "ubuntu";
          imageDigest = "sha256:99c35190e22d294cdace2783ac55effc69d32896daaa265f0bbedbcde4fbe3e5";
          sha256 = "03srdhmiii3f07rf29k17sipz8f88kydg7hj8awjqsv4jzq7an81";
          finalImageName = "ubuntu";
          finalImageTag = "latest";
          os = "linux";
          arch = "arm64";
        });

      aarch64-darwin.vscode-devcontainer = withSystem "aarch64-darwin" (hostCtx @ {self', ...}: let
        vscode-devcontainer = mkContainer {
          hostCtx = hostCtx // self';
          system = "aarch64-linux";
        };
      in
        vscode-devcontainer);
    };
  }
