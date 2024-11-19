{config, ...}: {
  ezConfigs = {
    darwin = {
      configurationsDirectory = "${config.ezConfigs.root}/configurations/darwin";
      modulesDirectory = "${config.ezConfigs.root}/modules/darwin";
      hosts = {
        nixbook-air.userHomeModules = ["krad246"];
        nixbook-pro.userHomeModules = ["krad246"];
        dullahan.userHomeModules = ["krad246"];
      };
    };
  };
}
