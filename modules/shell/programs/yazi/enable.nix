{
  flake.modules.homeManager.yazi = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "yazi" "enable"]
        ["programs" "yazi" "enable"]
      )
    ];
  };
}
