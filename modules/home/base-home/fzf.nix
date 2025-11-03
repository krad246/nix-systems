{
  config,
  lib,
  ...
}: {
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = ''
      ${lib.meta.getExe config.programs.fd.package}
    '';

    fileWidgetCommand = ''
      ${lib.meta.getExe config.programs.fd.package}
    '';

    fileWidgetOptions = let
      args = lib.cli.toGNUCommandLineShell {} {
        preview = ''
          ${lib.meta.getExe config.programs.bat.package} --color=always --style=numbers {}
        '';
      };
    in [
      args
    ];

    changeDirWidgetCommand = ''
      ${lib.meta.getExe config.programs.fd.package} --type d
    '';
  };
}
