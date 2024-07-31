{self, ...}: {
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    builderName = "docker-builder";

    docker-builder = pkgs.dockerTools.buildImage {
      name = builderName;
      copyToRoot = [
        pkgs.dockerTools.binSh
        pkgs.coreutils
        pkgs.nix
      ];

      config = let
        WorkingDir = "/workdir";
      in {
        Volumes = {
          "${WorkingDir}" = {};
        };

        inherit WorkingDir;
      };
    };

    dockerPlatormMap = {
      "x86_64-linux" = "linux/amd64";
      "aarch64-linux" = "linux/arm64";
    };

    docker-builder-exec = let
      workdir = docker-builder.passthru.buildArgs.config.WorkingDir;
    in
      pkgs.writeShellApplication {
        name = "${builderName}-exec";
        text = ''
          WORKDIR=${workdir}
          IMAGE="$(docker load -i ${docker-builder} | sed -nr 's/^Loaded image: (.*)$/\1/p')"
          docker run \
            --platform "${dockerPlatormMap.${system}}" \
            -v "${self}":"${workdir}":ro \
           "$IMAGE" sh -c "$*"
        '';
      };
  in {
    packages = lib.mkIf pkgs.stdenv.isLinux {
      inherit docker-builder;
      inherit docker-builder-exec;
    };
  };
}
