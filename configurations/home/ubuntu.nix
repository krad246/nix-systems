{self, ...}: {
  imports = [
    self.homeModules.base-home
  ];

  home = {
    username = "ubuntu";
    homeDirectory = "/home/ubuntu";
  };
}
