{
  flake.modules.homeManager.ripgrep = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.shell.programs.ripgrep;
  in {
    options.shell.programs.ripgrep.integrations.bat.enable =
      lib.options.mkEnableOption "Whether to enable `ripgrep` integration for `bat`.";

    config = {
      assertions = [
        {
          assertion = cfg.integrations.bat.enable -> cfg.enable;
          message = ''
            Setting `shell.programs.ripgrep.integrations.bat.enable` requires `shell.programs.ripgrep.enable`.
          '';
        }
      ];

      programs.bat.extraPackages = [pkgs.bat-extras.batgrep];
      home.shellAliases.brg = lib.modules.mkIf cfg.integrations.bat.enable "batgrep";
    };
  };
}
