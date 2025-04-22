{
  withSystem,
  self,
  specialArgs,
  config,
  lib,
  pkgs,
  ...
}: let
  machine = self.nixosConfigurations.fortress;
  inherit (specialArgs) krad246;

  dependencies =
    [
      machine.config.system.build.toplevel
      machine.config.system.build.build.diskoScript
      machine.config.system.build.diskoScript.drvPath
      machine.pkgs.stdenv.drvPath
      (machine.pkgs.closureInfo {rootPaths = [];}).drvPath

      machine.pkgs.perlPackages.ConfigIniFiles
      machine.pkgs.perlPackages.FileSlurp
    ]
    ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);

  closureInfo = pkgs.closureInfo {rootPaths = dependencies;};

  disko-install = pkgs.writeShellApplication {
    name = "disko-install";

    text = let
      installer = withSystem pkgs.stdenv.system ({self', ...}: self'.packages.disko-install);
      bin = lib.meta.getExe installer;
    in ''
      ${krad246.cli.toGNUCommandLineShell bin {
        system-config = builtins.toJSON {};
      }}
    '';
  };
in {
  environment.etc."install-closure".source = "${closureInfo}/store-paths";
  environment.systemPackages = [
    disko-install
  ];
}
