{
  flake.modules.homeManager.man = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "man" "enable"]
        ["programs" "man" "enable"]
      )
    ];

    programs.man.generateCaches = true;
  };
}
