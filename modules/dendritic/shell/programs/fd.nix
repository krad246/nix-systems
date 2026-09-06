{lib, ...}: {
  flake.modules.homeManager.fd = {
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
