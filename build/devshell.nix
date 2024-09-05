{
  self,
  inputs,
  ...
}: let
  mkDockerRun = {
    pkgs,
    platform,
    ...
  }:
    pkgs.writeShellApplication {
      name = "docker-run";
      text = let
        img = self.packages.${platform}."docker/devshell";
        platPkgs = import inputs.nixpkgs {system = platform;};
      in ''
        set -x
        docker load < ${img}
        WORKDIR="$(cat <(docker image inspect -f '{{.Config.WorkingDir}}' ${img.imageName}:${img.imageTag}))"
        docker run -it \
          --privileged \
          --platform linux/${platPkgs.go.GOARCH} \
          --net host \
          -v "$PWD:$WORKDIR" \
          ${img.imageName}:${img.imageTag}
      '';
    };

  mkDocker = {
    pkgs,
    platform ? pkgs.stdenv.system,
    ...
  }: let
    inherit (pkgs) lib;
  in {
    "docker/${platform}" = pkgs.mkShell {
      shellHook = ''
        ${lib.getExe (mkDockerRun {inherit pkgs platform;})}
      '';
    };
  };
in {
  perSystem = {
    self',
    config,
    lib,
    pkgs,
    ...
  }: {
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
      // lib.attrsets.optionalAttrs pkgs.stdenv.isLinux (mkDocker {inherit pkgs;});
  };

  flake = {
    devShells.aarch64-darwin =
      (mkDocker {
        pkgs = import inputs.nixpkgs {system = "aarch64-darwin";};
        platform = "aarch64-linux";
      })
      // (mkDocker {
        pkgs = import inputs.nixpkgs {system = "aarch64-darwin";};
        platform = "x86_64-linux";
      });
  };
}
