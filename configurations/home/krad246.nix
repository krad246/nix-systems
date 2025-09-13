{
  self,
  osConfig,
  pkgs,
  ...
}: {
  imports =
    [
      self.homeModules.base-home
    ]
    ++ (with self.modules.generic; [
      krad246-cachix
      nix-core
      flake-registry
      home-link-registry
    ]);

  home = {
    username = osConfig.users.users.krad246.name or "krad246";
    homeDirectory =
      osConfig.users.users.krad246.home
      or (
        if pkgs.stdenv.isDarwin
        then "/Users/krad246"
        else "/home/krad246"
      );
  };

  programs.git.userEmail = "condor-janitor0e@icloud.com";
}
