{
  perSystem = {
    lib,
    pkgs,
    system,
    self',
    ...
  }: let
    dockerPlatforms = {
      "x86_64-linux" = {
        os = "linux";
        arch = "amd64";
      };

      "i386-linux" = {
        os = "linux";
        arch = "i386";
      };

      "aarch64-linux" = {
        os = "linux";
        arch = "arm64";
      };

      "aarch64-darwin" = {
        os = "linux";
        arch = "arm64";
      };
    };

    dockerVMPlatform = dockerPlatforms."${system}";

    nixosCustomizations = lib.nixosSystem {
      inherit system;
      modules = [
        {
          boot.tmp.useTmpfs = true;
          nix.settings.experimental-features = ["nix-command" "flakes"];
          system.stateVersion = lib.trivial.release;
        }
      ];
    };
  in {
    packages = lib.mkIf pkgs.stdenv.isLinux {
      "docker/image/stream" = pkgs.dockerTools.streamLayeredImage {
        name = "docker-image-stream";
        contents = [
          pkgs.dockerTools.binSh
          pkgs.util-linux
          pkgs.coreutils
          pkgs.nixFlakes
          pkgs.git
        ];

        config = let
          WorkingDir = "/workdir";
        in {
          Volumes = {
            "${WorkingDir}" = {};
          };

          inherit WorkingDir;
        };

        architecture = dockerVMPlatform.arch;

        maxLayers = 32;
        enableFakechroot = true;
        fakeRootCommands = ''
          mkdir -p /{etc,tmp}
          ${nixosCustomizations.config.system.build.etcActivationCommands}
        '';
      };

      "docker/image/build" = pkgs.dockerTools.buildImageWithNixDb {
        name = "docker-image-build";
        architecture = dockerVMPlatform.arch;

        copyToRoot = pkgs.buildEnv {
          name = "docker-image-root";
          paths =
            (with pkgs.dockerTools; [usrBinEnv binSh caCertificates fakeNss])
            ++ (with pkgs; [
              coreutils
              nixFlakes
              git
              bashInteractive
            ]);
        };

        extraCommands = ''
          mkdir -p tmp
        '';

        config = let
          WorkingDir = "/workdir";
        in {
          Env = [];

          Volumes = {
            "${WorkingDir}" = {};
          };

          inherit WorkingDir;
        };
      };

      "docker/image/import" = pkgs.writeShellApplication {
        name = "docker-image-import";
        text = let
          img = self'.packages."docker/image/build";
        in ''
          if docker image inspect ${img.imageName}:${img.imageTag} "$@"; then
            true
          else
            docker load -q < ${img}
          fi
        '';
      };

      "docker/container/run" = pkgs.writeShellApplication {
        name = "docker-container-run";
        runtimeInputs = [self'.packages."docker/image/import"];
        text = ''
          set -x
          ID="$(cat <(docker-image-import --format '{{.Id}}'))"
          docker run -it --rm --net=host \
            -v "$FLAKE_ROOT:$(docker image inspect "$ID" --format='{{ .Config.WorkingDir }}'):ro" \
            "$ID" \
            "$@"
        '';
      };
    };
  };
}
