{
  config,
  lib,
  pkgs,
  ...
}: {
  ezConfigs = {
    home = {
      configurationsDirectory = "${config.ezConfigs.root}/configurations/home";
      modulesDirectory = "${config.ezConfigs.root}/modules/home";

      users = {
        keerad = {
          # Generate only one WSL config; requires a matching Windows user
          nameFunction = _name: "keerad@windex";

          # Standalone configuration independent of the host
          standalone = let
            impure = !lib.trivial.inPureEvalMode;
          in {
            enable = impure;
            inherit pkgs;
          };
        };
      };
    };
  };
}
