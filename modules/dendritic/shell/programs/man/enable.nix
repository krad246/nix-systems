{lib, ...}: {
  flake.modules.homeManager.man = {
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
