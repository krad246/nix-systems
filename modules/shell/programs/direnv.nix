{lib, ...}: {
  flake.modules.homeManager.direnv = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "direnv" "enable"]
        ["programs" "direnv" "enable"]
      )
    ];

    programs.direnv.nix-direnv.enable = true;
  };
}
