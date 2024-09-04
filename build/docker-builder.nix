{
  perSystem = {
    self',
    lib,
    pkgs,
    system,
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
    };
  in {
    packages = let
      contents =
        (with pkgs.dockerTools; [usrBinEnv binSh caCertificates fakeNss])
        ++ (with pkgs; [
          coreutils
          nixFlakes
          git
          bashInteractive
        ]);

      copyToRoot = pkgs.buildEnv {
        name = "docker-image-root";
        paths = contents;
      };

      dockerVMPlatform = dockerPlatforms."${system}";
      architecture = dockerVMPlatform.arch;
      containerCfg = let
        WorkingDir = "/workdir";
      in {
        Env = [];

        Volumes = {
          "${WorkingDir}" = {};
        };

        inherit WorkingDir;
      };

      runCommands = ''
        mkdir -p /tmp
      '';
    in
      lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        "docker/devshell" = let
          whoami = pkgs.runCommand "whoami" {} ''
            echo "{ \"uid\": \"$(id -u)\", \"gid\": \"$(id -g)\" }" >"$out"
          '';
          me = builtins.fromJSON (builtins.readFile whoami);
        in
          pkgs.dockerTools.buildNixShellImage {
            drv = self'.devShells.nix-shell;
            inherit (me) uid gid;
          };

        "docker/image" = pkgs.dockerTools.buildImageWithNixDb {
          name = "docker-image";
          inherit architecture;
          inherit copyToRoot;
          runAsRoot = runCommands;
          config = containerCfg;
        };

        "docker/image/multilayer" = pkgs.dockerTools.buildLayeredImageWithNixDb {
          name = "docker-image-multilayer";
          inherit architecture;
          inherit contents;
          fakeRootCommands = runCommands;
          config = containerCfg;
        };
      };
  };
}
