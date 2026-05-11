{lib, ...}: {
  flake.modules.homeManager.bottom = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "bottom" "enable"]
        ["programs" "bottom" "enable"]
      )
    ];
  };
}
