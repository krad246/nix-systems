{
  flake.modules.homeManager.starship = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "starship" "enable"]
        ["programs" "starship" "enable"]
      )
    ];
  };
}
