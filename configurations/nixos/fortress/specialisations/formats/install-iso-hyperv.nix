{pkgs, ...}: {
  imports = [
    ./hyperv.nix
    ./install-iso.nix
  ];

  environment.systemPackages = with pkgs; [
    calamares-nixos
    calamares-nixos-extensions
  ];

  disko.enableConfig = false;
}
