{lib, ...}: {
  flake.modules.homeManager.git = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "git" "integrations" "gh" "enable"]
        ["programs" "gh" "gitCredentialHelper" "enable"]
      )
    ];
  };
}
