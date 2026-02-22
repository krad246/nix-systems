{
  flake.modules.homeManager.lorri = {lib, ...}: {
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
