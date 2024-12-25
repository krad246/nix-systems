{
  self,
  config,
  ...
}: {
  imports = [
    self.homeModules.shellenv
    self.homeModules.dconf
  ];

  home = {
    username = "ubuntu";
    homeDirectory = "/home/ubuntu";
  };

  nix.settings = {
    trusted-users = ["${config.home.username}"];
  };
}
