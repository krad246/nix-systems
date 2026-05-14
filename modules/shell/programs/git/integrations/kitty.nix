{lib, ...}: {
  flake.modules.homeManager.git = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "git" "integrations" "kitty" "enable"]
        ["programs" "kitty" "enableGitIntegration"]
      )
    ];
  };
}
