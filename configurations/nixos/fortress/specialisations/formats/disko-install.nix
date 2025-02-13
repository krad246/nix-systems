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
  inherit (machine.config.system) build;
  inherit (specialArgs) krad246;

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
