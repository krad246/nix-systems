{lib, ...}: {
  flake.modules.nixos.systemd-boot = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["boot" "loader" "backends" "systemd-boot" "enable"]
        ["boot" "loader" "systemd-boot" "enable"]
      )
    ];
  };
}
