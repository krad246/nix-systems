args @ {
  inputs,
  config,
  lib,
  ...
}: let
  inherit (inputs) agenix;
  isHomeModule = lib.attrsets.hasAttrByPath ["osConfig"] args;
  configSource =
    if isHomeModule
    then args.osConfig
    else config;

  inherit (configSource.networking) hostName;
in {
  imports =
    lib.optionals isHomeModule [agenix.homeManagerModules.age];

  age = let
    # determine if there is a supported host
    maybeHostDir = lib.fileset.maybeMissing ./hosts/${hostName};

    # pull in the secrets bound to the host
    findAgeFiles = path: lib.fileset.fileFilter (file: file.hasExt "age") path;
    ageFiles = findAgeFiles ./hosts;
    hits = lib.fileset.toList (lib.fileset.intersection maybeHostDir ageFiles);

    # for a given secret path, convert it into an agenix compatible attrset.
    mkSecret = path: let
      bname = builtins.baseNameOf path;
      attrname = bname;
    in {
      "${attrname}" = {
        file = path;
      };
    };
    hostSecrets = lib.lists.forEach hits mkSecret;
  in {
    secrets = lib.attrsets.mergeAttrsList hostSecrets;
  };
}
