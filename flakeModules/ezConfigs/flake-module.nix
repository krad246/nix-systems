{
  getSystem,
  moduleWithSystem,
  withSystem,
  inputs,
  self,
  lib,
  config,
  ...
}: {
  imports = [inputs.ez-configs.flakeModule];

  # set ehllie/ez-configs modules options
  ezConfigs = let
    configRoot = config.ezConfigs.root + "/configurations";
    modulesRoot = config.ezConfigs.root + "/modules";
    args = {
      inherit getSystem moduleWithSystem withSystem;
      inherit inputs self;
    };
  in {
    root = self;
    # globalArgs = {
    #   inherit getSystem moduleWithSystem withSystem;
    #   inherit inputs self;
    # };

    nixos = {
      earlyModuleArgs = args;
      modulesDirectory = modulesRoot + "/nixos";

      configurationsDirectory = configRoot + "/nixos";
      hosts = {
        windex.userHomeModules = ["keerad" "krad246"];
        fortress.userHomeModules = ["krad246"];
      };
    };

    darwin = {
      earlyModuleArgs = args;
      modulesDirectory = modulesRoot + "/darwin";

      configurationsDirectory = configRoot + "/darwin";
      hosts = {
        nixbook-air.userHomeModules = ["krad246"];
        nixbook-pro.userHomeModules = ["krad246"];
        dullahan.userHomeModules = ["krad246"];
        gremlin.userHomeModules = ["krad246"];
      };
    };

    home = {
      earlyModuleArgs = args;
      modulesDirectory = modulesRoot + "/home";

      configurationsDirectory = configRoot + "/home";
      users = {
        keerad = {
          nameFunction = _name: "keerad@windex";
        };

        generic-linux.standalone = {
          enable = !lib.trivial.inPureEvalMode;
          pkgs = withSystem builtins.currentSystem ({
            config,
            inputs',
            system,
            ...
          }: let
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
              overlays = [
                (_: prev: {
                  kitty = prev.symlinkJoin {
                    name = "kitty-nixGL";
                    paths = [prev.kitty];
                    nativeBuildInputs = [prev.makeWrapper];
                    postBuild = ''
                      rm -f "$out/bin/kitty"
                      makeWrapper ${lib.meta.getExe inputs'.nixGL.packages.nixGLDefault} "$out/bin/kitty" \
                        --add-flags ${lib.meta.getExe prev.kitty}
                    '';
                  };
                })
              ];
            };
          in
            if pkgs.stdenv.isLinux
            then pkgs
            else throw "Only available for Linux stdenvs.");
        };
      };
    };
  };
}
