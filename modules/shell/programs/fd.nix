{
  flake.modules.homeManager.fd = {lib, ...}: {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "fd" "enable"]
        ["programs" "fd" "enable"]
      )
    ];

    programs.fd.extraOptions = [
      "--hyperlink auto"
    ];
  };
}
