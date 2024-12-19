{
  withSystem,
  config,
  ...
}: {
  ezConfigs = {
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
