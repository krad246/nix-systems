{lib, ...}: {
  flake.modules.homeManager.diff = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "diff" "backends" "delta" "integrations" "git" "enable"]
        ["programs" "delta" "enableGitIntegration"]
      )
    ];
  };
}
