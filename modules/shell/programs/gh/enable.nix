{lib, ...}: {
  flake.modules.homeManager.gh = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "gh" "enable"]
        ["programs" "gh" "enable"]
      )
    ];
  };
}
