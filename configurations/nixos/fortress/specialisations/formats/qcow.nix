_: {
  disabledModules = [../efiboot.nix];

  disko.enableConfig = false;
  virtualisation.diskSize = 64 * 1024;
}
