{
  withSystem,
  importApply,
  self,
  inputs,
  ...
}: {lib, ...}: {
  # pull in the default flake module so that we can, y'know, build stuff...
  imports =
    (with inputs; [
      flake-parts.flakeModules.modules
      flake-parts.flakeModules.flakeModules
    ])
    ++ (let
      entrypoint = import ./flake {inherit withSystem importApply self inputs;};
    in [entrypoint.flakeModule]);

  # scan subdirs for other modules
  flake.modules = let
    mkModules = dir: let
      # get a list of all .nix files
      findNix = path: lib.fileset.fileFilter (file: file.hasExt "nix") path;
      hits = lib.fileset.toList (findNix dir);
      # for each nix file, create a key value pair of the form:
      # { "${filename}" = import "${filename}"; }
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
    generic = mkModules ./generic;
    darwin = mkModules ./darwin;
    nixos = mkModules ./nixos;
    home = mkModules ./home;
  };
}
