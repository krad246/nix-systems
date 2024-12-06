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
    ripgrep = lib.meta.getExe config.programs.ripgrep.package;
  };
}
