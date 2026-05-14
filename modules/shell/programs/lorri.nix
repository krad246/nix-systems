{lib, ...}: {
  flake.modules.homeManager.lorri = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "lorri" "enable"]
        ["services" "lorri" "enable"]
      )
    ];

    # services.lorri = {
    #   enableNotifications = true;
    # };
  };
}
