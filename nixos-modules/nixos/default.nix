{inputs, ...}: let
  inherit (inputs) home-manager;
in {
  imports =
    [
      ./agenix.nix
      ./binfmt.nix
      ./ccache-stdenv.nix
      ./default-users.nix
      ./environment.nix
      ./flake-registry.nix
      ./kernel.nix
      ./nix-daemon.nix
      ./nix-ld.nix
      ./packages.nix
      ./unfree.nix
      ./zram.nix
    ]
    ++ [
      home-manager.nixosModules.home-manager
    ];
}
