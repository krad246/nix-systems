{lib, ...}: {
  flake.modules.homeManager.fzf = {
    config,
    pkgs,
    ...
  }: {
    options.picker.backends.fzf.integrations.bat.enable =
      lib.options.mkEnableOption "Bat preview and view actions for FZF";

    config.picker.actions = {
      preview = {
        enable = lib.modules.mkDefault config.picker.backends.fzf.integrations.bat.enable;
        command = lib.modules.mkIf config.picker.backends.fzf.integrations.bat.enable (lib.modules.mkDefault (lib.meta.getExe (pkgs.unstable.fzf-preview.override {
          bat = config.programs.bat.package;
        })));
      };
      view = {
        enable = lib.modules.mkDefault config.picker.backends.fzf.integrations.bat.enable;
        command = lib.modules.mkIf config.picker.backends.fzf.integrations.bat.enable (lib.modules.mkDefault (lib.strings.concatStringsSep " " [
          (lib.meta.getExe config.programs.bat.package)
          (lib.cli.toGNUCommandLineShell {} {paging = "always";})
        ]));
      };
    };
  };
}
