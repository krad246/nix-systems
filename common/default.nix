{lib, ...}: let
  # pull in the secrets bound to the host
  findNix = path: lib.fileset.fileFilter (file: file.hasExt "nix" && file.name != "default.nix") path;
  nixFiles = findNix ./.;
  hits = lib.fileset.toList nixFiles;

  mkModule = path: let
    bname = builtins.baseNameOf path;
    attrname = lib.strings.removeSuffix ".nix" bname;
  in {
    "${attrname}" = {
      imports = [path];
    };
  };

  modules = lib.lists.forEach hits mkModule;
in {
  flake.modules.generic = lib.attrsets.mergeAttrsList modules;
}
