{lib, ...}: {
  flake.modules.homeManager.yazi = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "yazi" "enable"]
        ["programs" "yazi" "enable"]
      )
    ];
  };
}
