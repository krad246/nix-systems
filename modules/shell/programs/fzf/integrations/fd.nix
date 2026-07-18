{lib, ...}: {
  flake.modules.homeManager.fzf = {config, ...}: {
    options.picker.backends.fzf.integrations.fd.enable =
      lib.options.mkEnableOption "FD candidate sources for FZF";

    config.picker.sources = {
      files = {
        enable = lib.modules.mkDefault config.picker.backends.fzf.integrations.fd.enable;
        command = lib.modules.mkIf config.picker.backends.fzf.integrations.fd.enable (lib.modules.mkDefault (lib.meta.getExe config.programs.fd.package));
      };
      directories = {
        enable = lib.modules.mkDefault config.picker.backends.fzf.integrations.fd.enable;
        command = lib.modules.mkIf config.picker.backends.fzf.integrations.fd.enable (lib.modules.mkDefault (lib.strings.concatStringsSep " " [
          (lib.meta.getExe config.programs.fd.package)
          (lib.cli.toGNUCommandLineShell {} {type = "d";})
        ]));
      };
    };
  };
}
