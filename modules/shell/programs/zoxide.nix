{
  flake.modules.homeManager.zoxide = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "zoxide" "enable"]
        ["programs" "zoxide" "enable"]
      )
    ];
  };
}
