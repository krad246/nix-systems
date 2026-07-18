{lib, ...}: {
  flake.modules.generic.input-registry = {
    config,
    options,
    ...
  }: let
    cfg = config.input-registry.sysroot;
    isHomeManager = options ? home.file;
  in {
    options.input-registry.sysroot = {
      install = lib.options.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to install the input registry entries to the filesystem.";
      };

      destination = {
        directory = lib.options.mkOption {
          type = lib.types.str;
          internal = true;
          default =
            if isHomeManager
            then config.home.homeDirectory
            else "/etc";
          readOnly = true;
        };

        prefix = lib.options.mkOption {
          type = lib.types.str;
          default = "/nix/path";
          description = "Subpath under /etc or $HOME to link input registry items under.";
          apply = v: lib.path.subpath.normalise ("./" + v);
        };
      };

      abspath = lib.options.mkOption {
        type = lib.types.str;
        internal = true;
        readOnly = true;
      };
    };

    config = let
      linkRegistryTo = prefix:
        lib.attrsets.mapAttrs' (
          name: value: {
            name = lib.path.subpath.join [prefix name];
            value.source = value.to.path;
          }
        );

      attrpath =
        if isHomeManager
        then ["home" "file"]
        else ["environment" "etc"];
    in
      lib.modules.mkMerge [
        {
          input-registry.sysroot.abspath = lib.strings.join "/" [
            cfg.destination.directory
            cfg.destination.prefix
          ];
        }
        (lib.modules.mkIf cfg.install (lib.attrsets.setAttrByPath attrpath (linkRegistryTo cfg.destination.prefix config.nix.registry)))
      ];
  };
}
