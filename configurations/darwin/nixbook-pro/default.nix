{
  imports = [
    ./configuration.nix
    ./remotes.nix
  ];

  nixpkgs.system = "aarch64-darwin";
}
