{self, ...}: {
  flake.modules.nixos.headless = {
    imports = with self.modules.nixos; [
      base
      terminfo
    ];
  };
}
