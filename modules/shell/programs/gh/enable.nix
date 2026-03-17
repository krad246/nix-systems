{
  flake.modules.homeManager.gh = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "gh" "enable"]
        ["programs" "gh" "enable"]
      )
    ];
  };
}
