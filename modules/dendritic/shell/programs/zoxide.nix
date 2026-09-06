{lib, ...}: {
  flake.modules.homeManager.zoxide = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "zoxide" "enable"]
        ["programs" "zoxide" "enable"]
      )
    ];
  };
}
