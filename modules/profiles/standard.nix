{self, ...}: {
  flake.modules.nixos.standard = {
    imports = [
      self.modules.nixos.base
    ];

    boot.tmp = {
      cleanOnBoot = true;
      # useTmpfs = lib.modules.mkDefault true;
    };

    # environment.sessionVariables.NIX_REMOTE = "daemon";

    programs.nix-ld.enable = true;
  };
}
