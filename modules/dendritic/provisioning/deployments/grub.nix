{
  flake.modules.nixos.deployment = {
    boot.loader = {
      efi.canTouchEfiVariables = false;
      grub.efiInstallAsRemovable = true;
    };
  };
}
