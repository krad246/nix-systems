{
  config,
  modulesPath,
  ...
}: {
  imports = ["${modulesPath}/virtualisation/qemu-vm.nix"];

  system.build.image = config.system.build.vm;
}
