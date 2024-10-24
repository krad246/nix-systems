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
                ++ [nix]
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
    flake.packages = let
      pullImage = pkgs: metadata:
        pkgs.dockerTools.pullImage (metadata
          // {
            os = pkgs.go.GOOS;
            arch = pkgs.go.GOARCH;
          });
    in
      {
        x86_64-linux = withSystem "x86_64-linux" ({pkgs, ...}: {
          ubuntu = pullImage pkgs {
            imageName = "ubuntu";
            imageDigest = "sha256:99c35190e22d294cdace2783ac55effc69d32896daaa265f0bbedbcde4fbe3e5";
            sha256 = "0j32w10gl1p87xj8kll0m2dgfizc3l2jnsdj4n95l960d4a4pmfa";
            finalImageName = "ubuntu";
            finalImageTag = "latest";
          };

          nix-flakes = pullImage pkgs {
            imageName = "nixpkgs/nix-flakes";
            imageDigest = "sha256:a6de74beafbf1d1934e615b98602f1975e146ab7a3154e97139b615cb804d467";
            sha256 = "0fxyvs2sxmfhj9i70wh23m2licx2waj7z1z5iy0gf6nlkm3j72cf";
            finalImageName = "nixpkgs/nix-flakes";
            finalImageTag = "latest";
          };

          nixos = pullImage pkgs {
            imageName = "nixos/nix";
            imageDigest = "sha256:fd7a5c67d396fe6bddeb9c10779d97541ab3a1b2a9d744df3754a99add4046f1";
            sha256 = "1ggkwd9zw8lj97ig7zah7dqy463hfhsgq3iwxxf8117gf8xi422s";
            finalImageName = "nixos/nix";
            finalImageTag = "latest";
          };
        });
      }
      // {
        aarch64-linux = withSystem "aarch64-linux" ({pkgs, ...}: {
          ubuntu = pullImage pkgs {
            imageName = "ubuntu";
            imageDigest = "sha256:99c35190e22d294cdace2783ac55effc69d32896daaa265f0bbedbcde4fbe3e5";
            sha256 = "03srdhmiii3f07rf29k17sipz8f88kydg7hj8awjqsv4jzq7an81";
            finalImageName = "ubuntu";
            finalImageTag = "latest";
          };

          nix-flakes = pullImage pkgs {
            imageName = "nixpkgs/nix-flakes";
            imageDigest = "sha256:a6de74beafbf1d1934e615b98602f1975e146ab7a3154e97139b615cb804d467";
            sha256 = "1kd83s9y26jsrnwy4gxchl6ir2c8p8h95m2f22p070p32ig3ljxb";
            finalImageName = "nixpkgs/nix-flakes";
            finalImageTag = "latest";
          };

          nixos = pullImage pkgs {
            imageName = "nixos/nix";
            imageDigest = "sha256:fd7a5c67d396fe6bddeb9c10779d97541ab3a1b2a9d744df3754a99add4046f1";
            sha256 = "0lyjvwkblsyylgdb6hw2iw1rk5nm19znap6hrijnwfy0alk83fjh";
            finalImageName = "nixos/nix";
            finalImageTag = "latest";
          };
        });
      }
      // {
        aarch64-darwin.vscode-devcontainer = withSystem "aarch64-darwin" (hostCtx @ {self', ...}: let
          vscode-devcontainer = mkContainer {
            hostCtx = hostCtx // self'; # forcibly instantiate self' in hostCtx
            system = "aarch64-linux";
          };
        in
          vscode-devcontainer);
      };
  }
