{
  self,
  lib,
  ...
}: {
  flake.modules = {
    homeManager.standalone = {
      config,
      pkgs,
      ...
    }: {
      imports = with self.modules.homeManager; [
        base
        home-manager
      ];

      home = {
        username = lib.modules.mkDefault config.identity.person.username;
        homeDirectory = lib.modules.mkDefault (
          if pkgs.stdenv.hostPlatform.isDarwin
          then "/Users/${config.identity.person.username}"
          else "/home/${config.identity.person.username}"
        );
      };

      nix.package = lib.modules.mkDefault pkgs.nix;
    };

    homeManager.standalone-workstation = {
      imports = with self.modules.homeManager; [
        standalone
        desktop
        dev
        secrets
      ];

      browser.backends.zen = {
        enable = lib.modules.mkDefault true;
        default = lib.modules.mkDefault true;
      };
    };
  };
}
