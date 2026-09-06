{self, ...}: {
  flake.modules.homeManager.codex = {pkgs, ...}: {
    imports = [self.modules.homeManager.nixpkgs-unstable];

    programs.codex.package = pkgs.unstable.codex;
  };
}
