{self, ...}: {
  imports =
    [
      ./aarch64-binfmt.nix
      ./agenix.nix
      ./default-users.nix
      ./environment.nix
      ./hm-compat.nix
      ./kernel.nix
      ./nerdfonts.nix
      ./nix-ld.nix
      ./packages.nix
    ]
    ++ (with self.nixosModules; [
      ccache-stdenv
      zram
    ])
    ++ (with self.modules.generic; [
      system-link-registry
      flake-registry
      nix-core
      unfree
    ]);
}
