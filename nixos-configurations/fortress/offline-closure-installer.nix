{
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

  nixos-install-unattended = pkgs.writeShellApplication {
    name = "nixos-install-unattended";
    text = let
      installer = self.packages.${pkgs.stdenv.system}.nixos-install-unattended;
    in ''
      ${lib.getExe installer} --system-config '${builtins.toJSON {}}' "$@"
    '';
  };
in {
  environment.etc."install-closure".source = "${closureInfo}/store-paths";
  environment.systemPackages = [
    nixos-install-unattended
  ];
}
