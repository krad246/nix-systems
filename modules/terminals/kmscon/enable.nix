{lib, ...}: {
  flake.modules.nixos.kmscon = {config, ...}: {
    options.terminal.backends.kmscon.enable =
      lib.options.mkEnableOption "kmscon as an active local-console terminal backend";

    config.services.kmscon.enable =
      lib.modules.mkDefault config.terminal.backends.kmscon.enable;
  };
}
