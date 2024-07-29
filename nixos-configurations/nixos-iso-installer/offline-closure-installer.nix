{
  self,
  lib,
  pkgs,
  ...
}: let
  machine = self.nixosConfigurations.immutable-gnome;
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
  system.includeBuildDependencies = false;

  environment.etc."install-closure".source = "${closureInfo}/store-paths";
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install-nixos-unattended" ''
      set -eux
      exec ${lib.getExe pkgs.disko} --flake "${self}#immutable-gnome" --disk main "$1"
    '')
  ];
}
