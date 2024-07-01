{
  self,
  pkgs,
  ...
}: let
  install-target = "immutable-gnome";
  device = "/dev/nvme0n1";

  machine = self.nixosConfigurations."${install-target}";
  dependencies =
    [
      machine.config.system.build.toplevel
      machine.config.system.build.diskoScript
      machine.pkgs.stdenv.drvPath
      (machine.pkgs.closureInfo {rootPaths = [];}).drvPath
    ]
    ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);

  closureInfo = pkgs.closureInfo {rootPaths = dependencies;};
in {
  environment.etc."install-closure".source = "${closureInfo}/store-paths";
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install-nixos-unattended" ''
      set -eux
      exec ${pkgs.disko}/bin/disko-install --flake "${self}#${install-target}" --disk main "${device}"
    '')
  ];
}
