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

    WorkingDir = "/workdir";
  in {
    packages = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isLinux {
        "docker/stream" = pkgs.dockerTools.streamLayeredImage {
          name = "docker-stream";
          fromImage = self'.packages."nixos/nix";
          contents = [
            pkgs.dockerTools.binSh
            pkgs.util-linux
            pkgs.coreutils
            pkgs.nixFlakes
            pkgs.git
          ];

          config = {
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
      })
      {
        "nixos/nix" = pkgs.dockerTools.pullImage {
          imageName = "nixos/nix";
          imageDigest = "sha256:5a2a7ee72e88528ff9422f16a8a0be580d8c173928369a20e8a6ba77a55cd95d";
          sha256 = "1jh1bdydfxprz54nmxx0yz2anwswkb1ny9d7gbh98zq02kkasjvf";
          finalImageName = "nixos/nix";
          finalImageTag = "latest";

          inherit (dockerVMPlatform) os arch;
        };

        "docker/image" = pkgs.dockerTools.buildImage {
          name = "docker-image";
          fromImage = self'.packages."nixos/nix";
          architecture = dockerVMPlatform.arch;
        };
      }
    ];
  };
}
