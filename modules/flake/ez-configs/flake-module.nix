# importApply context
{
  importApply,
  getSystem,
  moduleWithSystem,
  withSystem,
  inputs,
  self,
  lib,
  ...
}:
# module context as seen by the flake
{config, ...}: {
  imports = [inputs.ez-configs.flakeModule];

  # set ehllie/ez-configs modules options
  ezConfigs = let
    configRoot = config.ezConfigs.root + "/configurations";
    modulesRoot = config.ezConfigs.root + "/modules";
  in {
    root = self;
    globalArgs = {
      inherit importApply;
      inherit getSystem moduleWithSystem withSystem;
      inherit inputs self;
      inherit (lib) krad246;
    };

    nixos = {
      configurationsDirectory = configRoot + "/nixos";
      modulesDirectory = modulesRoot + "/nixos";
      hosts = {
        windex = {
          importDefault = false;
          userHomeModules = ["keerad" "krad246"];
        };
        fortress = {
          importDefault = false;
          userHomeModules = ["krad246"];
        };
      };
    };

    darwin = {
      configurationsDirectory = configRoot + "/darwin";
      modulesDirectory = modulesRoot + "/darwin";
      hosts = {
        nixbook-air = {
          importDefault = false;
          userHomeModules = ["krad246"];
        };
        nixbook-pro = {
          importDefault = false;
          userHomeModules = ["krad246"];
        };
        dullahan = {
          importDefault = false;
          userHomeModules = ["krad246"];
        };
      };
    };

    home = {
      configurationsDirectory = configRoot + "/home";
      modulesDirectory = modulesRoot + "/home";

      users = {
        keerad = {
          importDefault = true;
          nameFunction = _name: "keerad@windex";
        };

        ubuntu = {
          importDefault = true;
          nameFunction = _name: "ubuntu";

          standalone = let
            system = builtins.currentSystem;
          in {
            enable = true;
            pkgs = withSystem system ({pkgs, ...}:
              if pkgs.stdenv.isLinux
              then pkgs
              else throw "Only available for Linux");
          };
        };
      };
    };
  };
}
