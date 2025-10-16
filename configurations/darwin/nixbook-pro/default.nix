{lib, ...}: {
  imports = [
    ./configuration.nix
    ./remotes.nix
  ];

  nixpkgs.system = lib.modules.mkDefault "aarch64-darwin";
}
