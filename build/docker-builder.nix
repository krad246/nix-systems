{
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    nixosCustomizations = lib.nixosSystem {
      inherit system;
      modules = [
        {
          environment.etc."some-config-file" = {
            text = ''
              127.0.0.1 localhost
              ::1 localhost
            '';
          };
        }
      ];
    };

    builderName = "docker-builder";
    WorkingDir = "/workdir";

    docker-nixos-nix-image = pkgs.dockerTools.pullImage {
      imageName = "nixos/nix";
      imageDigest = "sha256:5a2a7ee72e88528ff9422f16a8a0be580d8c173928369a20e8a6ba77a55cd95d";
      sha256 = "1jh1bdydfxprz54nmxx0yz2anwswkb1ny9d7gbh98zq02kkasjvf";
      finalImageName = "nixos/nix";
      finalImageTag = "latest";
    };

    docker-builder = pkgs.dockerTools.streamLayeredImage {
      name = builderName;
      fromImage = null;
      contents = [
        pkgs.dockerTools.binSh
        pkgs.util-linux
        pkgs.coreutils
      ];

      config = {
        Volumes = {
          "${WorkingDir}" = {};
        };

        inherit WorkingDir;
      };

      maxLayers = 32;
      enableFakechroot = true;
      fakeRootCommands = ''
        mkdir -p /etc && \
          ${nixosCustomizations.config.system.build.etcActivationCommands}
      '';
    };

    dockerPlatormMap = {
      "x86_64-linux" = "linux/amd64";
      "aarch64-linux" = "linux/arm64";
    };

    docker-builder-exec = pkgs.writeShellApplication {
      name = "${builderName}-exec";
      text = ''
        set -eux
        WORKDIR=${WorkingDir}
        IMAGE="$(${docker-builder} | docker image load | sed -nr 's/^Loaded image: (.*)$/\1/p')"
        docker run \
          --platform "${dockerPlatormMap.${system}}" \
          -v "$FLAKE_ROOT":"$WORKDIR":ro \
          -it \
         "$IMAGE" "$@"
      '';
    };
  in {
    packages = lib.mkIf pkgs.stdenv.isLinux {
      inherit docker-builder;
      inherit docker-builder-exec;
      inherit docker-nixos-nix-image;
    };
  };
}
