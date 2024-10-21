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

        fromImage = mappedCtx.self'.packages.nix-flakes;

        contents = let
          mkEnv = {pkgs, ...}:
            pkgs.buildEnv {
              name = "vscode-devcontainer-contents";
              paths = with pkgs;
                [bashInteractive]
                # FIXME: you'd essentially have to repeat the nixos-vscode-server setup here in
                # order to completely avoid setup here. Instead, prefer to merge nix-flakes with the
                # ubuntu container so that this is unnecessary. keeps package environment cleaner.
                ++ [busybox nodejs]
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

          # fake out /etc/os-release for devcontainers.
          cat <<- EOF >./etc/os-release
          ANSI_COLOR="1;34"
          BUG_REPORT_URL="https://github.com/NixOS/nixpkgs/issues"
          DOCUMENTATION_URL="https://nixos.org/learn.html"
          HOME_URL="https://nixos.org/"
          ID=nixos
          IMAGE_ID=""
          IMAGE_VERSION=""
          LOGO="nix-snowflake"
          NAME=NixOS
          SUPPORT_URL="https://nixos.org/community.html"
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

      x86_64-linux.nix-flakes = withSystem "x86_64-linux" ({pkgs, ...}:
        pkgs.dockerTools.pullImage {
          imageName = "nixpkgs/nix-flakes";
          imageDigest = "sha256:a6de74beafbf1d1934e615b98602f1975e146ab7a3154e97139b615cb804d467";
          sha256 = "0fxyvs2sxmfhj9i70wh23m2licx2waj7z1z5iy0gf6nlkm3j72cf";
          finalImageName = "nixpkgs/nix-flakes";
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

      aarch64-linux.nix-flakes = withSystem "aarch64-linux" ({pkgs, ...}:
        pkgs.dockerTools.pullImage {
          imageName = "nixpkgs/nix-flakes";
          imageDigest = "sha256:a6de74beafbf1d1934e615b98602f1975e146ab7a3154e97139b615cb804d467";
          sha256 = "1kd83s9y26jsrnwy4gxchl6ir2c8p8h95m2f22p070p32ig3ljxb";
          finalImageName = "nixpkgs/nix-flakes";
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
