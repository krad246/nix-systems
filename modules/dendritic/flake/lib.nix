{
  inputs,
  self,
  ...
}: {
  flake.lib = inputs.nixpkgs.lib;

  perSystem = {system, ...}:
    self.lib.mkMerge [
      (self.lib.mkIf (system == "aarch64-darwin") {
        checks.flake-lib-nixbook-pro = let
          cfg = self.darwinConfigurations.nixbook-pro.config;
          home = cfg.home-manager.users.${cfg.owner.username};
        in
          assert self.lib.trivial.release == inputs.nixpkgs.lib.trivial.release;
          assert home.home.stateVersion == self.lib.trivial.release;
          assert home.xdg.enable;
          assert home.manual.json.enable;
          assert !home.manual.html.enable;
            home.home.activationPackage;
      })
      (self.lib.mkIf (system == "aarch64-linux") {
        checks.flake-lib-miniboi = let
          cfg = self.nixosConfigurations.miniboi.config;
          home = cfg.home-manager.users.${cfg.owner.username};
        in
          assert self.lib.trivial.release == inputs.nixpkgs.lib.trivial.release;
          assert cfg.system.stateVersion == self.lib.trivial.release;
          assert home.home.stateVersion == self.lib.trivial.release;
          assert home.xdg.enable;
          assert home.manual.json.enable;
          assert !home.manual.html.enable;
            cfg.system.build.toplevel;
      })
    ];
}
