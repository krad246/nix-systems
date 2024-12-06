{withSystem, ...}: let
  # Form a container mapping a streamLayeredImage script from a given 'hostCtx'
  # to a target 'system'.
  mkContainer = {
    hostCtx,
    system ? hostCtx.pkgs.stdenv.system,
    ...
  }:
    withSystem system (mappedCtx: let
      vscode-devcontainer = hostCtx.pkgs.dockerTools.streamLayeredImage {
        name = "vscode-devcontainer";

        # Based on Ubuntu 22.04 of the mapped architecture
        fromImage = mappedCtx.self'.packages.ubuntu;
        architecture = mappedCtx.pkgs.go.GOARCH;

        contents = let
          mkEnv = {pkgs, ...}:
            pkgs.buildEnv {
              name = "vscode-devcontainer-env";
              paths = with pkgs;
                [bashInteractive git]
                ++ [toybox less lesspipe util-linux]
                ++ [nix just]
                ++ [
                  dockerTools.binSh
                  dockerTools.usrBinEnv
                ];

              pathsToLink = ["/bin"];
            };
        in
          mkEnv mappedCtx;

        config.Env = mappedCtx.pkgs.lib.mapAttrsToList (name: value: "${name}=${value}") ({
            # Provide the Nix install certificate paths for internet access.
            SSL_CERT_FILE = "${mappedCtx.pkgs.dockerTools.caCertificates}/etc/ssl/certs/ca-bundle.crt";
            NIX_SSL_CERT_FILE = "${mappedCtx.pkgs.dockerTools.caCertificates}/etc/ssl/certs/ca-bundle.crt";
          }
          // {
            NIX_BUILD_CORES = "1"; # Seems to reduce the odds of OOM killing (maybe?) by slowing things down...
          }
          // {
            TERM = "xterm-256color";
          });

        # Reconfigure the Nix install as single-user, but with flake support.
        extraCommands = ''
          mkdir -p ./etc/nix

          cat <<- EOF >./etc/nix/nix.conf
          build-users-group =
          experimental-features = nix-command flakes
          EOF
        '';

        enableFakechroot = hostCtx.pkgs.stdenv.isLinux;
        fakeRootCommands = ''
        '';
      };
    in
      vscode-devcontainer);
in
  {
    perSystem = args @ {
      self',
      lib,
      pkgs,
      ...
    }: {
      packages = lib.modules.mkIf pkgs.stdenv.isLinux {
        vscode-devcontainer = self'.packages."vscode-devcontainer-${pkgs.stdenv.system}";
        "vscode-devcontainer-${pkgs.stdenv.system}" = mkContainer {hostCtx = args;};
      };
    };
  }
  // {
    flake.packages =
      {
        x86_64-linux = withSystem "x86_64-linux" (hostCtx @ {self', ...}: {
          vscode-devcontainer-aarch64-linux = let
            vscode-devcontainer = mkContainer {
              hostCtx = hostCtx // self'; # forcibly instantiate self' in hostCtx
              system = "aarch64-linux";
            };
          in
            vscode-devcontainer;
        });
      }
      // {
        aarch64-linux = withSystem "aarch64-linux" (hostCtx @ {self', ...}: {
          vscode-devcontainer-x86_64-linux = let
            vscode-devcontainer = mkContainer {
              hostCtx = hostCtx // self'; # forcibly instantiate self' in hostCtx
              system = "x86_64-linux";
            };
          in
            vscode-devcontainer;
        });
      }
      // {
        aarch64-darwin = rec {
          vscode-devcontainer = vscode-devcontainer-aarch64-linux;

          vscode-devcontainer-aarch64-linux = withSystem "aarch64-darwin" (hostCtx @ {self', ...}: let
            vscode-devcontainer = mkContainer {
              hostCtx = hostCtx // self'; # forcibly instantiate self' in hostCtx
              system = "aarch64-linux";
            };
          in
            vscode-devcontainer);

          vscode-devcontainer-x86_64-linux = withSystem "aarch64-darwin" (hostCtx @ {self', ...}: let
            vscode-devcontainer = mkContainer {
              hostCtx = hostCtx // self'; # forcibly instantiate self' in hostCtx
              system = "x86_64-linux";
            };
          in
            vscode-devcontainer);
        };
      };
  }
