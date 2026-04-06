{inputs, ...}: {
  flake.modules.nixos.disko = {lib, ...}: {
    imports = [inputs.disko.nixosModules.disko];

    disko = {
      enableConfig = lib.modules.mkDefault false;
      imageBuilder.enableBinfmt = true;
      checkScripts = true;
    };

    # image.modules.disko-vm = {config, ...}: {
    #   system.build.image = config.system.build.vmWithDisko;
    # };
  };
}
