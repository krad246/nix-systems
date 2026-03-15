{
  flake.modules.homeManager.man = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.shell.programs.man;
  in {
    options.shell.programs.man.integrations.bat.enable =
      lib.options.mkEnableOption "Whether to enable `bat` integration for `man` pages.";

    config = {
      assertions = [
        {
          assertion = cfg.integrations.bat.enable -> cfg.enable;
          message = ''
            Setting `shell.programs.man.integrations.bat.enable` requires `shell.programs.man.enable`.
          '';
        }
      ];

      programs.bat.extraPackages = [pkgs.bat-extras.batman];
      home.shellAliases.man = lib.modules.mkIf cfg.integrations.bat.enable "batman";
    };
  };
}
