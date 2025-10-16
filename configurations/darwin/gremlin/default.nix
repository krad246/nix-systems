{lib, ...}: {
  imports = [
    ./configuration.nix
    ./hercules-ci-agent
    ./remotes.nix
  ];

  nixpkgs.system = lib.modules.mkDefault "aarch64-darwin";
}
