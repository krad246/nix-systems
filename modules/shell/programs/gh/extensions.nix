{lib, ...}: {
  flake.modules.homeManager.gh = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.shell.programs.gh;
  in {
    programs = {
      gh-dash = lib.modules.mkIf cfg.enable {
        # enable = false;
        settings = {
        };
      };

      gh.extensions = with pkgs; [
        gh-poi
        # gh-markdown-preview # needs browser
        # gh-eco # meh
        # gh-s
        # gh-f
      ];
    };
  };
}
