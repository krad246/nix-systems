{
  self,
  pkgs,
  lib,
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
    (pkgs.writeShellScriptBin "install-nixos-unattended" ''
      ${lib.getExe' pkgs.disko "disko-install"} \
        --flake "${self}#${nixosConfig.config.networking.hostName}" \
        --extra-files "${self}" /opt/nixos \
        --option inputs-from "${self}" \
        --option experimental-features 'nix-command flakes' \
        --write-efi-boot-entries \
        --system-config '${builtins.toJSON {}}' \
      "$@"
    '')
  ];
}
