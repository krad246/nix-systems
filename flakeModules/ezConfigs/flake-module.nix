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

    # FIXME(dendritic-hosts): Legacy Windex and Fortress roots are temporarily
    # omitted because their incomplete boot and legacy IFD paths fail CI.
    # Restore Windex through dendritic.configurations.hosts; Fortress follows
    # when its image and boot specialisation declarations migrate.

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
