# importApply context
{
  importApply,
  getSystem,
  moduleWithSystem,
  withSystem,
  inputs,
  self,
  specialArgs,
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
      inherit (specialArgs) krad246;
    };

    nixos = {
      configurationsDirectory = configRoot + "/nixos";
      modulesDirectory = modulesRoot + "/nixos";
      hosts = {
        windex.userHomeModules = ["keerad" "krad246"];
        fortress.userHomeModules = ["krad246"];
      };
    };

    darwin = {
      configurationsDirectory = configRoot + "/darwin";
      modulesDirectory = modulesRoot + "/darwin";
      hosts = {
        nixbook-air.userHomeModules = ["krad246"];
        nixbook-pro.userHomeModules = ["krad246"];
        dullahan.userHomeModules = ["krad246"];
      };
    };

    home = {
      configurationsDirectory = configRoot + "/home";
      modulesDirectory = modulesRoot + "/home";

      users = {
        keerad = {
          nameFunction = _name: "keerad@windex";
        };

        ubuntu = {
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
