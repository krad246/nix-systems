{
  flake.modules.homeManager.pager = {
    config,
    lib,
    ...
  }: let
    cfg = config.shell.programs.pager;
  in {
    options.shell.programs.pager.integrations.bat.enable =
      lib.options.mkEnableOption "Whether to enable `bat` integration for `less`.";

    config = {
      assertions = [
        {
          assertion = cfg.integrations.bat.enable -> cfg.enable;
          message = ''
            Setting `shell.programs.pager.integrations.bat.enable` requires `shell.programs.pager.enable`.
          '';
        }
      ];

      programs.lesspipe.enable = lib.modules.mkIf cfg.integrations.bat.enable false;
    };
  };
}
