{
  flake.modules.homeManager.bottom = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "bottom" "enable"]
        ["programs" "bottom" "enable"]
      )
    ];
  };
}
