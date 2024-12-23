{
  self,
  config,
  lib,
  ...
}: {
  imports = [
    self.homeModules.shellenv
    self.homeModules.dconf
  ];

  home = {
    username = "ubuntu";
    homeDirectory = "/home/ubuntu";

    stateVersion = lib.trivial.release;
  };

  nix.settings = {
    trusted-users = ["${config.home.username}"];
  };
}
