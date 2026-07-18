{lib, ...}: {
  flake.modules.homeManager.codex = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "codex" "enable"]
        ["programs" "codex" "enable"]
      )
    ];
  };
}
