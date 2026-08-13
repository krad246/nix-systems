{
  getSystem,
  moduleWithSystem,
  withSystem,
  inputs,
  self,
  config,
  ...
}: {
  imports = [inputs.ez-configs.flakeModule];

  # set ehllie/ez-configs modules options
  ezConfigs = let
    configRoot = config.ezConfigs.root + "/configurations";
    modulesRoot = config.ezConfigs.root + "/modules";
  in {
    root = self;
    globalArgs = {
      inherit getSystem moduleWithSystem withSystem;
      inherit inputs self;
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
        gremlin.userHomeModules = ["krad246"];
      };
    };

    home = {
      configurationsDirectory = configRoot + "/home";
      modulesDirectory = modulesRoot + "/home";

      users = {
        keerad = {
          nameFunction = _name: "keerad@windex";
        };
      };
    };
  };
}
