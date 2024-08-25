{
  self,
  pkgs,
  specialArgs,
  ...
}: let
  inherit (specialArgs) nixosConfig;
  inherit (nixosConfig.config.system) build;

  dependencies =
    [
      build.toplevel
      build.diskoScript
    ]
    ++ [
      nixosConfig.pkgs.stdenv.drvPath
      (nixosConfig.pkgs.closureInfo {rootPaths = [];}).drvPath
    ]
    ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);

  closureInfo = pkgs.closureInfo {rootPaths = dependencies;};
in {
  system.includeBuildDependencies = false;
  environment.etc."install-closure".source = "${closureInfo}/store-paths";
  environment.systemPackages = [
    self.packages.${pkgs.stdenv.system}.nixos-install
  ];
}
