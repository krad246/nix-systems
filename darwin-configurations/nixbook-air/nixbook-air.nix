{
  imports = [
    ../../darwin-modules/darwin
    ../../darwin-modules/flake-registry.nix
    ../../darwin-modules/homebrew
    ../../darwin-modules/linux-builder.nix
  ];

  users.users.krad246 = {
    home = "/Users/krad246";
    createHome = true;
  };

  nix.settings = {
    allowed-users = ["krad246" "@admin"];
    trusted-users = ["krad246" "@admin"];
  };

  homebrew = {
    casks = ["arc"] ++ ["bluesnooze"] ++ ["docker"] ++ ["signal"] ++ ["vmware-fusion"];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
}
