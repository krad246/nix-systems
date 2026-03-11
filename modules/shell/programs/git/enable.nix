{
  flake.modules.homeManager.git = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "git" "enable"]
        ["programs" "git" "enable"]
      )
    ];
  };
}
