{self, ...}: {
  imports = with self.nixosModules; [nixos nerdfonts];
}
