{lib, ...}: {
  imports = [
    ./brew-casks.nix
    ./nixbook-air.nix
    ./remotes.nix
  ];
  nixpkgs.system = lib.modules.mkDefault "aarch64-darwin";
}
