{
  lib,
  config,
  ...
}: {
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--no-require-git"
    ];
  };

  home.shellAliases = {
    ripgrep = lib.getExe config.programs.ripgrep.package;
  };
}
