{config, ...}: {
  ezConfigs = {
    nixos = {
      configurationsDirectory = "${config.ezConfigs.root}/configurations/nixos";
      modulesDirectory = "${config.ezConfigs.root}/modules/nixos";
      hosts = {
        windex.userHomeModules = ["keerad" "krad246"];
        fortress.userHomeModules = ["krad246"];
      };
    };
  };
}
