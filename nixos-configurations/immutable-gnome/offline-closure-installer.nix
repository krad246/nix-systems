{
  self,
  pkgs,
  config,
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
in {
  environment.etc."install-closure".source = "${closureInfo}/store-paths";
  environment.systemPackages = [
    self.packages.${pkgs.stdenv.system}.nixos-install-unattended
  ];
}
