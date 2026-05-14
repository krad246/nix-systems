{lib, ...}: {
  flake.modules.homeManager.starship = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "starship" "enable"]
        ["programs" "starship" "enable"]
      )
    ];
  };
}
