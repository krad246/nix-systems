{lib, ...}: {
  flake.modules.homeManager.terminal = {
    options.terminal.backends.kitty.enable =
      lib.options.mkEnableOption "Kitty as an active terminal backend";
  };
}
