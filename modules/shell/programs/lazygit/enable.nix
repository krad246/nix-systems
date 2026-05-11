{lib, ...}: {
  flake.modules.homeManager.lazygit = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "lazygit" "enable"]
        ["programs" "lazygit" "enable"]
      )
    ];
  };
}
