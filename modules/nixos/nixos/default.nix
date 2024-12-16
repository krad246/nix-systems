{self, ...}: {
  imports =
    [
      self.nixosModules.ccache-stdenv
      self.nixosModules.darling
      self.nixosModules.hm-compat
      self.nixosModules.zram
    ]
    ++ [
      ./default-users.nix
      ./environment.nix
      ./kernel.nix
      ./nix-ld.nix
      ./packages.nix
    ]
    ++ (with self.modules.generic; [system-link-registry flake-registry nix-core unfree]);
}
