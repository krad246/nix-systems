{
  self,
  pkgs,
  specialArgs,
  ...
}: let
  inherit (specialArgs) nixosConfig;

  withDisko = nixosConfig;
  inherit (withDisko.config.system) build;

  dependencies =
    [
      build.toplevel
      build.diskoScript
    ]
    ++ [
      withDisko.pkgs.stdenv.drvPath
      (withDisko.pkgs.closureInfo {rootPaths = [];}).drvPath
    ]
    ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);

  closureInfo = pkgs.closureInfo {rootPaths = dependencies;};
in {
  system.includeBuildDependencies = false;

  environment.etc."install-closure".source = "${closureInfo}/store-paths";
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install-nixos-unattended" ''
      set -eux
      exec ${pkgs.disko}/bin/disko-install \
        --flake "${self}#${withDisko.config.networking.hostName}" \
        --extra-files "${self}" /opt/nixos \
        --option inputs-from "${self}" \
        --option experimental-features 'nix-command flakes' \
        --write-efi-boot-entries \
      "$@"
    '')
  ];
}
