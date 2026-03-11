{
  flake.modules.homeManager.git = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "git" "integrations" "kitty" "enable"]
        ["programs" "kitty" "enableGitIntegration"]
      )
    ];
  };
}
