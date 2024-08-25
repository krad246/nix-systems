{
  config,
  lib,
  pkgs,
  ...
}: {
  mkLaunchdUnit = {
    name,
    launchCfg,
    ...
  }: {
    launchd.agents."${name}" = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      config =
        launchCfg
        // {
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/${name}/stdout";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/${name}/stderr";
        };
    };
  };
}
