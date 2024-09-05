{
  self,
  inputs,
  ...
}: let
  mkDockerRun = {
    pkgs,
    sys,
    ...
  }:
    pkgs.writeShellApplication {
      name = "docker-run";
      text = let
        img = self.packages.${sys}."docker/devshell";
      in ''
        docker load < ${img}
        WORKDIR="$(cat <(docker image inspect -f '{{.Config.WorkingDir}}' ${img.imageName}:${img.imageTag}))"
        docker run -it \
          --net host \
          -v "$PWD:$WORKDIR" \
          ${img.imageName}:${img.imageTag}
      '';
    };

  dockerRun = {
    pkgs,
    sys ? pkgs.stdenv.system,
    ...
  }:
    mkDockerRun {
      inherit pkgs;
      inherit sys;
    };
in {
  flake = {
    devShells.aarch64-darwin = {
      docker = let
        pkgs = import inputs.nixpkgs {system = "aarch64-darwin";};
        inherit (pkgs) lib;
      in
        pkgs.mkShell {
          shellHook = ''
            exec ${lib.getExe (dockerRun {
              inherit pkgs;
              sys = "aarch64-linux";
            })}
          '';
        };
    };
  };

  perSystem = {
    self',
    config,
    lib,
    pkgs,
    ...
  }: {
    pre-commit.settings.hooks = {
      nil.enable = true;
      deadnix.enable = true;
      alejandra.enable = true;
      statix.enable = true;
    };

    devShells =
      {
        default = self'.devShells.nix-shell;
        nix-shell = pkgs.mkShell {
          inputsFrom = [
            config.flake-root.devShell
            config.just-flake.outputs.devShell
            config.treefmt.build.devShell
            config.pre-commit.devShell
          ];

          packages = with pkgs; [git direnv nix-direnv just ripgrep nixFlakes];
        };
      }
      // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        docker = let
          run = self'.packages."docker/run";
        in
          pkgs.mkShell {
            shellHook = ''
              exec ${lib.getExe run}
            '';
          };
      };

    packages =
      {
        default = self'.packages."build/all";
        "build/all" = pkgs.writeShellApplication {
          name = "build-all";
          text = ''
            ${lib.getExe pkgs.nix} flake lock --no-update-lock-file
            ${lib.getExe (pkgs.callPackage inputs.devour-flake {})} "$FLAKE_ROOT" "$@"
          '';
        };
      }
      // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        "docker/run" = dockerRun {inherit pkgs;};
      };
  };
}
