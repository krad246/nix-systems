{lib, ...}: {
  imports = [
    ./configuration.nix
    ./hercules-ci.nix
    ./secrets.nix
  ];

  nixpkgs.system = lib.modules.mkDefault "aarch64-darwin";
}
