{
  flake.modules.homeManager.bat = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "bat" "enable"]
        ["programs" "bat" "enable"]
      )
    ];
  };
}
