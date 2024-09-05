{
  perSystem = {
    self',
    lib,
    pkgs,
    ...
  }: {
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
            drv = self'.devShells.default;
            inherit (me) uid gid;
            # command = ''
            #   DEBUG=1 echo '${lib.getExe execTmpfs}'
            # '';
          };

        "docker/image" = pkgs.dockerTools.buildImageWithNixDb {
          name = "docker-image";
          arch = pkgs.go.GOARCH;
          inherit copyToRoot;
          runAsRoot = runCommands;
          config = containerCfg;
        };

        "docker/image/multilayer" = pkgs.dockerTools.buildLayeredImageWithNixDb {
          name = "docker-image-multilayer";
          arch = pkgs.go.GOARCH;
          inherit contents;
          fakeRootCommands = runCommands;
          config = containerCfg;
        };
      };
  };
}
