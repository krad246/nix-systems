{self, ...}: {
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    inherit (lib) attrsets lists;
    nixosConfigs = attrsets.attrValues self.nixosConfigurations;
    nixosMachines = lists.forEach nixosConfigs (nixosCfg: let
      machine = nixosCfg.extendModules {
        modules = [
          {
            nixpkgs.system = pkgs.stdenv.system;
          }
        ];
      };
    in
      machine);

    hostFormatName = nixosMachine: format: let
      inherit (nixosMachine.config.networking) hostName;
    in "${hostName}/${format}";

    mapHostFormat = nixosMachine: format: value:
      attrsets.nameValuePair
      (hostFormatName nixosMachine format)
      value;
  in {
    packages = let
      mkFormatPackages = nixosMachine: let
        declaredFormats = nixosMachine: let
          formats =
            attrsets.attrByPath ["config" "formats"] {}
            nixosMachine;

          include = [
            "hyperv"
            "iso"
            "install-iso"
            "install-iso-hyperv"
            "qcow"
            "qcow-efi"
            "raw"
            "raw-efi"
            "sd-aarch64"
            "sd-aarch64-installer"
            "sd-x86_64"
            "vagrant-virtualbox"
            "virtualbox"
            "vm"
            "vm-bootloader"
            "vm-nogui"
            "vmware"
          ];

          filtered = let
            included = name: (builtins.elem name include);
          in
            attrsets.filterAttrs (name: _value: included name) formats;
        in
          filtered;

        declared = declaredFormats nixosMachine;
      in
        attrsets.mapAttrs' (format: drv: mapHostFormat nixosMachine format drv)
        declared;

      formats = lists.forEach nixosMachines mkFormatPackages;
    in
      attrsets.mergeAttrsList (lists.flatten [
        (lists.optionals pkgs.stdenv.isLinux [formats])
      ]);
  };
}
