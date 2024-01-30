{inputs, ...}: let
  inherit (inputs) nixos-wsl;
in {
  imports = [nixos-wsl.nixosModules.wsl] ++ [./fstab.nix ./wsl.nix];
}
