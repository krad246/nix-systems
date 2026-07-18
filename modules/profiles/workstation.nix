{self, ...}: {
  flake.modules = {
    homeManager.workstation = {
      imports = with self.modules.homeManager; [
        base
        desktop
        dev
        secrets
      ];
    };

    darwin.workstation = {
      imports = with self.modules.darwin; [
        base
        desktop
        dev
        secrets
      ];
    };

    nixos.workstation = {
      imports = with self.modules.nixos; [
        base
        desktop
        dev
        secrets
      ];

      boot.tmp.cleanOnBoot = true;
      programs.nix-ld.enable = true;
    };
  };
}
