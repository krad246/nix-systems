{lib, ...}: {
  flake.modules.homeManager.git = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "git" "enable"]
        ["programs" "git" "enable"]
      )
    ];
  };
}
