{lib, ...}: {
  flake.modules.homeManager.diff = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "diff" "backends" "delta" "enable"]
        ["programs" "delta" "enable"]
      )
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "diff" "backends" "delta" "package"]
        ["programs" "delta" "package"]
      )
    ];

    programs.delta.options = {
      navigate = true;
      line-numbers = true;
      hyperlinks = true;
      side-by-side = true;
    };
  };
}
