{
  self,
  config,
  lib,
  ...
}: {
  imports = [
    self.homeModules.shellenv
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
