{
  self,
  lib,
  ...
}: {
  imports =
    [
      ./default-users.nix
      ./environment.nix
      ./kernel.nix
      ./nix-ld.nix
      ./packages.nix
    ]
    ++ [
      self.nixosModules.ccache-stdenv
      self.nixosModules.hm-compat
    ]
    ++ (with self.modules.generic; [
      system-link-registry
      flake-registry
      nix-core
      unfree
    ]);

  system.stateVersion = lib.trivial.release;
}
