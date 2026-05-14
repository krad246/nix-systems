{lib, ...}: {
  flake.modules.nixos.grub = {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["boot" "loader" "backends" "grub" "enable"]
        ["boot" "loader" "grub" "enable"]
      )
    ];
  };
}
