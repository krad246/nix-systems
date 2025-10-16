{lib, ...}: {
  imports = [
    ./configuration.nix
    ./container.nix
  ];
  nixpkgs.system = lib.modules.mkDefault "x86_64-linux";
}
