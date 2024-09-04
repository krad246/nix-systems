{inputs, ...}: {
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
          run-docker = pkgs.writeShellApplication {
            name = "docker";
            text = let
              img = self'.packages."docker/devshell";
            in ''
              docker load < ${img}
              WORKDIR="$(cat <(docker image inspect -f '{{.Config.WorkingDir}}' ${img.imageName}:${img.imageTag}))"
              docker run -it -v "$PWD:$WORKDIR" ${img.imageName}:${img.imageTag}
            '';
          };
        in
          pkgs.mkShell {
            shellHook = ''
              ${lib.getExe run-docker}
            '';
          };
      };

    packages = {
      default = self'.packages."build/all";
      "build/all" = pkgs.writeShellApplication {
        name = "build-all";
        text = ''
          ${lib.getExe pkgs.nix} flake lock --no-update-lock-file
          ${lib.getExe (pkgs.callPackage inputs.devour-flake {})} "$FLAKE_ROOT" "$@"
        '';
      };
    };
  };
}
