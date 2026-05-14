{lib, ...}: {
  flake.modules.homeManager.lsd = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "lsd" "enable"]
        ["programs" "lsd" "enable"]
      )
    ];
  };
}
