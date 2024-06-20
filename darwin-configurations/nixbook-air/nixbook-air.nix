{ezModules, ...}: let
  darwinModules = ezModules;
in {
  imports = with darwinModules; ([darwin linux-builder homebrew] ++ [arc signal] ++ [vmware]);

  users.users.krad246 = {
    home = "/Users/krad246";
    createHome = true;
  };

  nix.settings.trusted-users = ["krad246"];

  homebrew.casks = ["bluesnooze"] ++ ["docker"];
}
