{
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    builderName = "docker-builder";

    etc = let
      inherit (pkgs) lib;
      nixosCore = lib.evalModules {
        modules = [
          {
            environment.etc."/nix/nix.conf" = {
              text = ''
                extra-experimental-features = "nix-command flakes"
              '';
            };
          }
        ];
      };
    in
      pkgs.dockerTools.streamLayeredImage {
        name = "etc";
        tag = "latest";
        enableFakechroot = true;
        fakeRootCommands = ''
          mkdir -p /etc
          ${nixosCore.config.system.build.etcActivationCommands}
        '';
        config.Cmd = pkgs.writeScript "etc-cmd" ''
          #!${pkgs.busybox}/bin/sh
          ${pkgs.busybox}/bin/cat /etc/some-config-file
        '';
      };

    docker-builder = pkgs.dockerTools.buildImage {
      name = builderName;
      fromImage = pkgs.dockerTools.pullImage {
        imageName = "nixos/nix";
        imageDigest = "sha256:5a2a7ee72e88528ff9422f16a8a0be580d8c173928369a20e8a6ba77a55cd95d";
        sha256 = "1jh1bdydfxprz54nmxx0yz2anwswkb1ny9d7gbh98zq02kkasjvf";
        finalImageName = "nixos/nix";
        finalImageTag = "latest";
      };

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
            -v "$FLAKE_ROOT":"$WORKDIR":ro \
           "$IMAGE" sh -c "$*"
        '';
      };
  in {
    packages = lib.mkIf pkgs.stdenv.isLinux {
      inherit docker-builder;
      inherit docker-builder-exec;
      inherit etc;
    };
  };
}
