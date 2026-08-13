{
  self,
  lib,
  ...
}: {
  flake.modules = {
    homeManager.workstation = {
      imports = with self.modules.homeManager; [
        base
        desktop
        dev
        interactive
        secrets
      ];

      browser.backends.zen = {
        enable = lib.modules.mkDefault true;
        default = lib.modules.mkDefault true;
      };
    };

    darwin.workstation = {
      imports = with self.modules.darwin; [
        applications
        base
        desktop
        dev
        interactive
        secrets
      ];
    };

    nixos.workstation = {
      imports = with self.modules.nixos; [
        base
        desktop
        dev
        interactive
        secrets
      ];

      boot.tmp.cleanOnBoot = true;
      programs.nix-ld.enable = true;
    };
  };
}
