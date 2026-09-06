{lib, ...}: {
  flake.modules.homeManager.bat = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "bat" "enable"]
        ["programs" "bat" "enable"]
      )
    ];
  };
}
