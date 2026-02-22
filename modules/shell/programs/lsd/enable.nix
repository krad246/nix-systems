{
  flake.modules.homeManager.lsd = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "lsd" "enable"]
        ["programs" "lsd" "enable"]
      )
    ];
  };
}
