{
  lib,
  config,
  ...
}: {
  programs.ripgrep = {
    enable = true;
    arguments = [
    ];
  };

  home.shellAliases = {
    ripgrep = lib.getExe config.programs.ripgrep.package;
  };
}
