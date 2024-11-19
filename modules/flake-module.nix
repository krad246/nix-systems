_: {lib, ...}: let
  mkModules = dir: let
    findNix = path: lib.fileset.fileFilter (file: file.hasExt "nix") path;
    hits = lib.fileset.toList (findNix dir);
  in
    lib.attrsets.mergeAttrsList (lib.lists.forEach hits (mname: let
      bname = builtins.baseNameOf mname;
      attrname = lib.strings.removeSuffix ".nix" bname;
    in {
      "${attrname}" = {
        imports = [mname];
      };
    }));
in {
  flake.modules = {
    generic = mkModules ./generic;
    darwin = mkModules ./darwin;
    nixos = mkModules ./nixos;
    home = mkModules ./home;
    flake = mkModules ./flake;
  };
}
