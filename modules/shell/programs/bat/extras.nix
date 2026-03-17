{
  flake.modules.homeManager.bat = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.shell.programs.bat;
  in {
    programs.bat.extraPackages = with pkgs.bat-extras; [
      batdiff
      prettybat
    ];

    home.shellAliases = lib.modules.mkIf cfg.enable {
      bat = "prettybat";
      bdiff = "batdiff";
    };
  };
}
