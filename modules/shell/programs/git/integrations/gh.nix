{
  flake.modules.homeManager.git = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "git" "integrations" "gh" "enable"]
        ["programs" "gh" "gitCredentialHelper" "enable"]
      )
    ];
  };
}
