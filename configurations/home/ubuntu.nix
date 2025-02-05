{
  self,
  config,
  ...
}: {
  imports = [
    self.homeModules.base-home
  ];

  home = {
    username = "ubuntu";
    homeDirectory = "/home/ubuntu";
  };

  nix.settings = {
    trusted-users = ["${config.home.username}"];
  };
}
