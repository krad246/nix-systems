{
  config,
  lib,
  ...
}: {
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = lib.meta.getExe config.programs.fd.package;
    fileWidgetCommand = lib.meta.getExe config.programs.fd.package;
    changeDirWidgetCommand = lib.meta.getExe config.programs.fd.package;
  };
}
