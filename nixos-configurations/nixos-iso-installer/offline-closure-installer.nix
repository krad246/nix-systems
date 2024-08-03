{
  self,
  pkgs,
  ...
}: let
  machine = self.nixosConfigurations.immutable-gnome;
  inherit (machine.config.system) build;

  dependencies =
    [
      build.toplevel
      build.diskoScript
    ]
    ++ [
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
      exec ${pkgs.disko}/bin/disko-install --flake "${self}#${machine.config.networking.hostName}" --option inputs-from "${self}" "$@"
    '')
  ];
}
