{
  self,
  pkgs,
  lib,
  ...
}: let
  install-target = lib.debug.traceVal (builtins.getEnv "MACHINE");
  device = lib.debug.traceVal (builtins.getEnv "DEVICE");

  machine = self.nixosConfigurations."${install-target}";
  dependencies =
    [
      machine.config.system.build.toplevel
      machine.config.system.build.diskoScript
      pkgs.stdenv.drvPath
      (machine.pkgs.closureInfo {rootPaths = [];}).drvPath
    ]
    ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);

  closureInfo = pkgs.closureInfo {rootPaths = dependencies;};
in {
  # environment.etc."install-closure".source = "${closureInfo}/store-paths";
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install-nixos-unattended" ''
      set -eux
      # Replace "/dev/disk/by-id/some-disk-id" with your actual disk ID
      exec ${pkgs.disko}/bin/disko-install --flake "${self}#${install-target}" --disk main "${device}"
    '')
  ];
}
