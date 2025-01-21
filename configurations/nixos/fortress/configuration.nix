{
  self,
  lib,
  ...
}: {
  imports = with self.nixosModules; [
    gnome-desktop
    whitesur
  ];

  programs.dconf.enable = lib.modules.mkDefault true;

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi Radhakrishnan";
    extraGroups = ["wheel"];
    initialHashedPassword = "$y$j9T$GlfzmGjYcMf96CrZDYSKf.$vYN1YvO28MeOLulPK6wNc.RnnL5dN4c.pcR7ur/8jP9";
  };

  home-manager.sharedModules = [
    {imports = with self.homeModules; [vscode vscode-server];}
  ];
}
