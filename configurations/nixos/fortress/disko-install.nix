{
  withSystem,
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.networking) hostName;
  machine = self.nixosConfigurations."${hostName}";
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

  disko-install = pkgs.writeShellApplication {
    name = "disko-install";

    text = let
      installer = withSystem pkgs.stdenv.system ({self', ...}: self'.packages.disko-install);
      bin = lib.meta.getExe installer;
      args = lib.cli.toGNUCommandLine {} {
        system-config = builtins.toJSON {};
      };
    in ''
      ${bin} ${lib.strings.concatStringsSep " " args} "$@"
    '';
  };
in {
  environment.etc."install-closure".source = "${closureInfo}/store-paths";
  environment.systemPackages = [
    disko-install
  ];
}
