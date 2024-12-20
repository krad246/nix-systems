{inputs, ...}: {
  formatAttr = "vmWithDisko";
  virtualisation.vmVariantWithDisko = {
    virtualisation.host.pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
    disko.memSize = 6 * 1024;
  };
}
