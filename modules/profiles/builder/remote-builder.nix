{self, ...}: {
  flake.modules.nixos.remote-builder = {
    imports = with self.modules.nixos; [
      bottom
      builder
      nix
      swapspace
      terminfo
      zram
    ];

    environment.sessionVariables.TERM = "xterm-256color";
    systemd.coredump.enable = false;
  };
}
