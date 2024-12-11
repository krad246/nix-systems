{pkgs, ...}: {
  imports = [
    ./iso.nix
    ../disko-install.nix
  ];

  environment.systemPackages = with pkgs; [
    calamares-nixos
    calamares-nixos-extensions
  ];
}
