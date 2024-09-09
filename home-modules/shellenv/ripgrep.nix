{
  lib,
  config,
  ...
}: {
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--hidden"
      "--unrestricted"
    ];
  };

  home.shellAliases = {
    ripgrep = lib.getExe config.programs.ripgrep.package;
  };
}
