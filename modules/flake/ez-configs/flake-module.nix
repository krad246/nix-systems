{
  importApply,
  getSystem,
  moduleWithSystem,
  withSystem,
  inputs,
  self,
  specialArgs,
  ...
}: {config, ...}: {
  imports = [inputs.ez-configs.flakeModule];

  ezConfigs = {
    root = self;
    globalArgs = {
      inherit importApply;
      inherit getSystem moduleWithSystem withSystem;
      inherit inputs self;
      inherit (specialArgs) krad246;
    };

    nixos = {
      configurationsDirectory = "${config.ezConfigs.root}/configurations/nixos";
      modulesDirectory = "${config.ezConfigs.root}/modules/nixos";
      hosts = {
        windex.userHomeModules = ["keerad" "krad246"];
        fortress.userHomeModules = ["krad246"];
      };
    };

    darwin = {
      configurationsDirectory = "${config.ezConfigs.root}/configurations/darwin";
      modulesDirectory = "${config.ezConfigs.root}/modules/darwin";
      hosts = {
        nixbook-air.userHomeModules = ["krad246"];
        nixbook-pro.userHomeModules = ["krad246"];
        dullahan.userHomeModules = ["krad246"];
      };
    };

    home = {
      configurationsDirectory = "${config.ezConfigs.root}/configurations/home";
      modulesDirectory = "${config.ezConfigs.root}/modules/home";

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
