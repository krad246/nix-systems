{
  flake.modules.homeManager.lazygit = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "lazygit" "enable"]
        ["programs" "lazygit" "enable"]
      )
    ];
  };
}
